In this exercise, you will learn how to set up an EAP cluster on OpenShift. 

<!-- https://github.com/coreos/etcd-operator/blob/master/doc/user/spec_examples.md -->

# Build the test cluster image    

Clone the repository:

```execute 
cd ~/ && rm -rf cluster-test 

git clone https://github.com/sjbylo/cluster-test.git 
```

and change into the directory and list its content: 

```execute
cd cluster-test 
ls -l 
```

Notice the ``cluster_test.war`` prebuilt war file?  We will use this for this exercise.  But, how do we easily get this war file into a container image and run it? 

First, create a "binary" build object. This is a build configuration that accepts a java ``war`` file as input.  The following command will create the build object instructing it to use the JBoss EAP 7.2 builder image (``jboss-eap72-openshift``) and to accept the war file as input from a local directory (using the ``--binary`` option).  

Create the build configuration object: 

```execute
oc new-build openshift/jboss-eap72-openshift:1.0 \
    --binary \
    --name eap-cluster 
```

Start the build.  A build pod will be started and the ``war`` file will be uploaded into the running builder pod from the current working directory ".":

```execute 
oc start-build eap-cluster --from-dir=. --follow
```
The ``war`` file will be copied into place inside the container, so look out for the following output: 

```
...
INFO Copying deployments from . to /deployments...
'/tmp/src/./cluster_test.war' -> '/deployments/cluster_test.war'
...
```

... the container is then committed (new image created of the tunning container).  Look out for the following:

```
...
STEP 10: COMMIT temp.builder.openshift.io/lab-ocp4-qqthl/eap-cluster-1:dca674da
...
```

... and pushed into the internal registry:

```
Successfully pushed ...
```

**Building the image will take a few minutes**.

Once you see the message ``Push successful``, you can continue with the rest of the exercise. 

---

# Launch the test cluster application 

First of all, let's be able to observe what's happening.  We will execute a ``watch`` command in the lower terminal window that shows the various pods in your project/namespace).  Run this command: 

```execute-2
watch "oc get po | grep -v -e ^NAME -e \-deploy -e Completed" 
```

Now, create & launch the application using the image you created in the previous steps.  We do that with the OpenShift's ``new-app`` command: 

```execute
oc new-app eap-cluster --name eap-cluster 
```
This command will find the ``eap-cluster`` image and then add all the various Kubernetes objects (service and deployment config) that are needed to launch, run and maintain the application over its lifetime. 

<!--
```execute-2
watch "oc get po | grep -e eap-cluster -e ^NAME | grep -v -e \-deploy -e Completed" 
```
-->

Now, expose the application, creating a new ``route`` object: 

```execute
oc expose svc eap-cluster 
oc get route 
```

Let's fetch the ``route`` hostname into an environment variable (ROUTE) along with the context path (cluster_test/) so we can test the application later on: 

```execute
ROUTE=http://`oc get route eap-cluster -o template --template {{.spec.host}}`/cluster_test/
echo $ROUTE
```

The application can be reached at this endpoint. 

Wait for the pod to be ``Running`` and the application to finish starting up.  You can open the application ina browser using the above URL. 


# Configure the application 

**Disable sticky sessions**

By default, all OpenShift routes use sticky sessions.  The ingress controller (OpenShift Router using haproxy) will set a session cookie _of its own_ so it can direct returning traffic back to the same pod. 

So that we can test the cluster, change the route object so that it does not use sticky sessions.  Instead of sending the same user to the exact same pod (the default behavior), we will send requests to any pod using round-robbin:

```execute
oc annotate routes eap-cluster haproxy.router.openshift.io/disable_cookies='true'
```

More about configuring the behavior of OpenShift routes can be found in the OpenShift [documentation](https://docs.openshift.com/container-platform/3.11/architecture/networking/routes.html#route-specific-annotations).

**Configure probes**

We need to set the ``readiness`` probe correctly for the application.  This is to ensure that the OpenShift Router (ingress controller based on haproxy) only sends requests to the pods that are ready to receive the requests.  We also scale the application to 2 pods.

Run the following: 

```execute 
oc rollout pause dc eap-cluster

oc set probe dc/eap-cluster --readiness --get-url=http://:8080/cluster_test/ --initial-delay-seconds=10 --timeout-seconds=8

oc set probe dc/eap-cluster --liveness --initial-delay-seconds=30 --timeout-seconds=8 -- echo ok

oc scale dc/eap-cluster --replicas=2

oc rollout resume dc eap-cluster
```

We also set the ``liveness`` probe for good measure.  The ``liveness`` probe is used to ensure that the container itself is restarted should it fail. 

The application will be restarted automatically using these new settings. You can observe the rollout in the lower terminal window. 

Wait for the application to scale from 1 to 2 pods.  You should see something similar to:

```
NAME                   READY   STATUS      RESTARTS   AGE
eap-cluster-1-47v87    1/1     Running     0          3m23s
eap-cluster-1-9grc8    1/1     Running     0          2m3s
```

You will see both pods in ``Running`` state *and* both with a "READY" state of ``1/1`` (this means the pods are ready to receive traffic).

Run the following command:

```execute
oc rollout status dc eap-cluster --watch
```

When you see ``successfully rolled out``, then continue with the rest of the exercise. 

---

<!--
Wait for the rollout to finish, using the following command: 

```execute 
oc rollout status dc eap-cluster --watch
```
Once you see ``successfully rolled out`` then continue with the rest of the exercise. 
-->

# Test the application 

We will use ``curl`` to test the application. However you can also view it in your browser by going to the output of the following command:

```execute 
echo $ROUTE 
```

To show the cluster settings working, we will use a script ``test.sh`` which uses ``curl``. 

The following command will send 10 requests to the application.  The first request will open a session and save the session ID into a cookie file.  Subsequent requests will send the cookie with the same session ID so the server can identify the client: 

```execute 
./test.sh $ROUTE 0.1 10
```

What is the output of the test script? What do you see? Are the results as expected?  

Without clustering turn on, you should see varied results.  For example, since the pods are not yet clustered, only one pod holds the session data and can count the number of hits.   The other pod, without knowledge of the original session, always shows just 1 hit.

# Add clustering 

Let's turn on clustering.  To do this, we will need to create a service object which will help to track the cluster's IP addresses. 

Create the service object:

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
This service object will track our pods using the label "``deploymentconfig: eap-cluster``". 

Now, we need to configure each pod with the following environment variables which instructs EAP to run in clustering mode. Each pod in the cluster can discover each other's IP addresses via the service object (using DNS) created earlier. 

```execute
oc set env dc eap-cluster \
    JGROUPS_PING_PROTOCOL=openshift.DNS_PING \
    OPENSHIFT_DNS_PING_SERVICE_NAME=eap-cluster-ping \
    OPENSHIFT_DNS_PING_SERVICE_PORT=8888 
```
Setting these variable in the deployment configuration (dc) object in turn rolls out the application pods setting the values in each new pod. 

More can be read in the EAP for OpenShift cluster [documentation](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.2/html-single/getting_started_with_jboss_eap_for_openshift_container_platform/index#reference_clustering). 

Wait for the rollout to finish, using the following command: 

```execute 
oc rollout status dc eap-cluster --watch
```
Once you see ``successfully rolled out`` then continue with the rest of the exercise. 

---

Take a look at the application's logs:

```execute 
oc logs dc/eap-cluster | grep "joined the cluster"
```

You should see the following: 

```
"Node eap-cluster-10-xxyyzz joined the cluster"
```

Now, we have configured clustering and have verified it's started from the pod logs, let's test the application. 

You will see that all pods are now sharing the same session data.  This means that any pod can serve the requests of all users. 

```execute 
rm -f .cookie    # start a new session 
./test.sh $ROUTE 0.1 10
```

Now, all the pods can serve the same user session. 


Scale the application to 3 instances: 

```execute 
oc scale dc eap-cluster --replicas=3
```

Whilst the new pod is being added to the cluster, test the application to ensure the session data is still being shared amongst the cluster: 

```execute 
./test.sh $ROUTE 0.1 20
```

The cluster can still serve the same user session. 

Delete one instance of the EAP cluster (it will be replaced):

```execute
oc delete pod `oc get pod | grep eap-cluster | awk '{print $1}' | tail -1`
```

Whilst the pod is being healed (restarted), test the application again:

```execute 
./test.sh $ROUTE 0.1 20
```

The results should still show the session is shared between all pods and the correct hit count is shown. 

Start a new _rolling deployment_.  All pods will be replaced one after the other ensuring the application remains available:

```execute
oc rollout latest eap-cluster 
```

```execute 
./test.sh $ROUTE 0.1 
```

Notice that none of the session data is lost. 

# Clean up

Clean up the project:

```execute
oc delete all --selector=app=eap-cluster  
oc delete all --selector=build=eap-cluster  
oc delete svc eap-cluster-ping
cd ~/ && rm -rf cluster-test 
```

Stop the watch command:

```execute-2
<ctrl+c>
```

That's the end of the exercise.  You have created an EAP cluster and tested it using a test application.  You scaled the cluster, you failed a pod and you updated the application using the rolling update method.  
