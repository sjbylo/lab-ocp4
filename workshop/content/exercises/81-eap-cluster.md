In this exercise, you will learn how to set up an EAP cluster on OpenShift. 

# Build the test cluster image    

Clone the repository:

```execute 
cd ~/ && rm -rf cluster-test 
git clone https://github.com/sjbylo/cluster-test.git 
```

and change into the directory: 

```execute
cd cluster-test 
```

Now, create a "binary" build object. This is a build configuration that will accept a java ``war`` file as input.  The next command will create the build object instructing it to use the EAP 7.2 builder image (``jboss-eap72-openshift``) and to accept the source code as input from a local directory (that's the ``--binary`` option).  

Create the build configuration object: 

```execute
oc new-build openshift/jboss-eap72-openshift:1.0 --name eap-cluster --binary
```

Start the build.  A build pod will started and the ``war`` file will be uploaded from the current working directory ".":

```execute 
oc start-build eap-cluster --from-dir=. --follow
```
The ``war`` file will be copied into place inside the container, so look out for the following output: 

```
INFO Copying deployments from . to /deployments...
'/tmp/src/./cluster_test.war' -> '/deployments/cluster_test.war'
```

... the container is then committed:

```
STEP 10: COMMIT temp.builder.openshift.io/lab-ocp4-qqthl/eap-cluster-1:dca674da
```

... and pushed into the internal registry:

```
Successfully pushed ...
```

**Building the image will take a few minutes**.

Once you see the message ``Push successful``, you can continue with the rest of the exercise. 

# Launch the test cluster application 

Create & launch the application using the image that was created above.  We do that with the OpenShift's ``new-app`` command: 

```execute
oc new-app eap-cluster
```

Observe what's happening in the lower terminal window:

```execute-2
watch "oc get po | grep eap-cluster | grep -v -e \-deploy -e Completed" 
```


Now, expose the application, creating a new route object: 

```execute
oc expose svc eap-cluster 
oc get route 
```

Scale the application to 2 instances: 

```execute 
oc scale dc eap-cluster --replicas=2
```

Wait for the application to scale from 1 to 2 pods.  You should see something similar to:

```
NAME                   READY   STATUS      RESTARTS   AGE
eap-cluster-1-47v87    1/1     Running     0          3m23s
eap-cluster-1-9grc8    1/1     Running     0          2m3s
```

Once you see both pods in ``Running`` state *and* both with a "READY" state of ``1/1`` (this means the pods are ready to receive traffic), then continue. 

Let's fetch the ``route`` hostname into an environment variable (ROUTE) along with the context path (cluster_test/) so we can test the application: 

```execute
ROUTE=http://`oc get route eap-cluster -o template --template {{.spec.host}}`/cluster_test/
echo $ROUTE
```
Your application can be reached at this endpoint. 


# Disable sticky sessions 

By default, all OpenShift routes use sticky sessions.  The ingress controller (OpenShift Router using haproxy) will set a session cookie _of its own_ so it can direct returning traffic back to the same pod. 

Now, change the route object so that it does not use sticky sessions.  Instead of sending the same user to the exact same pod (the default behavior), we will send requests to any pod using round-robbin:

```execute
oc annotate routes eap-cluster haproxy.router.openshift.io/disable_cookies='true'
```

More about configuring the behavior of OpenShift routes can be found in the OpenShift [documentation](https://docs.openshift.com/container-platform/3.11/architecture/networking/routes.html#route-specific-annotations).


We need to set the ``readiness`` probe correctly for the application.  This is to ensure that the ingress router (haproxy) only sends requests to the pods that are ready to receive the requests.  

```execute 
oc rollout pause dc eap-cluster

oc set probe dc/eap-cluster --readiness --get-url=http://:8080/cluster_test/ --initial-delay-seconds=10 --timeout-seconds=8

oc set probe dc/eap-cluster --liveness --initial-delay-seconds=30 --timeout-seconds=8 -- echo ok

oc scale dc/eap-cluster --replicas=2

oc rollout resume dc eap-cluster
```

We also set the ``liveness`` probe for good measure.  The ``liveness`` probe is used to ensure that the container itself is restarted should it fail. 

The application will we restarted automatically using these new settings. You can observe the rollout in the lower terminal window. 

Wait for the rollout to finish, using the following command: 

```execute 
oc rollout  status dc eap-cluster -w
```
Once you see ``successfully rolled out`` then continue. 


# Test the application 

We will use ``curl`` to test the application. However you can also view it in your browser by going to the output of the following command:

```execute 
echo $ROUTE 
```

To show the cluster settings working, we will use a script ``test.sh`` which uses ``curl``. 

Set the initial cookie into a file (.cookie) using curl: 

```execute
curl -sc .cookie $ROUTE > /dev/null 2>&1
```

Send requests to the application using the application's session cookie. 

```execute
while true; do OUT=`curl -sb .cookie $ROUTE`; T1=`echo $OUT | sed "s/.*\(You have.*times\).*/\1/g"`;         T2=`echo "$OUT"| egrep "^[a-zA-Z0-9_-]{40}$"`; echo "$T2 $T1"; sleep 0.5; done
```

The following command will send 10 requests to the application.  The first request will open the session and save the session ID into a cookie file.  Subsequent requests will send the cookie with the same session ID so the server can identify the client: 

```execute 
./test.sh $ROUTE 0.1 10
```

```execute 
./test.sh $ROUTE 0.5 
```

Without clustering should get varied results. 

```execute
oc scale dc/eap-cluster --replicas=2
```

# Add clustering 

```execute
oc create -f - <<END
kind: Service
apiVersion: v1
spec:
    clusterIP: None
    ports:
    - name: ping
      port: 8888
    selector:
        deploymentconfig: eap-cluster
metadata:
    name: eap-cluster-ping
    annotations:
        service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
        description: "The JGroups ping port for clustering."
END
```

Now, we need to configure each pod with the following environment variables which instructs EAP to run in clustering mode. Each pod in the cluster can discover each other's IP addresses via the service object (using DNS) created earlier. 

```execute
oc set env dc eap-cluster \
    JGROUPS_PING_PROTOCOL=openshift.DNS_PING \
    OPENSHIFT_DNS_PING_SERVICE_NAME=eap-cluster-ping \
    OPENSHIFT_DNS_PING_SERVICE_PORT=8888 
```


Wait for the rollout to finish, using the following command: 

```execute 
oc rollout  status dc eap-cluster -w
```
Once you see ``successfully rolled out`` then continue. 

You should see in the pod's output the following or similar output: 

"Node eap-cluster-10-xxyyzz joined the cluster"


Now test the application.  You will see that all pods are now sharing the same session data.  This means that any pod can serve the requests of all users. 

```execute 
./test.sh $ROUTE 0.1 10
```

Scale the application to 3 instances: 

```execute 
oc scale dc eap-cluster --replicas=3
```

Test the application to ensure the session data is still being shared amongst the cluster: 

```execute 
./test.sh $ROUTE 0.1 10
```

Delete one instance of the EAP cluster (it will be replaced):

```execute
oc delete pod `oc get pod | grep eap-cluster | awk '{print $1}' | tail -1`
```

Whilst the pod is being healed, test the application again:

```execute 
./test.sh $ROUTE 0.1 10
```

# Clean up

Clean up the project 

```execute
oc delete all --selector=app=eap-cluster  
```
Stop the watch command:

```execute-2
<ctrl+c>
```

That's the end of the exercise.  You have created an EAP cluster and tested it using a test application.  You scaled the cluster, you failed a pod and you rolled out a new version of the application. 
