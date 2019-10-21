In this exercise you will learn about the Etcd Operator.

Go to the console page "[Installed Operators](%console_url%/ns/%project_namespace%/clusterserviceversions)" where the Etcd Operator should be seen.  
If it is not visible, then the OpenShift Platform Administrator needs to subscribe to it.

First, check what's running in your project:

```execute
oc get po
```

<!--
Clean up the project:

```execute
oc delete all --all 
```
-->

With the following command, we can observe the pods of the Etcd Cluster in the lower terminal:

```execute-2
watch "oc get pods | grep example | grep -v ' Completed '"
```
Leave this command running for the duration of this exercise.

Instantiate an Etcd Cluster by creating the EtcdCluster custom resource:

```execute
oc create -f - << END
apiVersion: etcd.database.coreos.com/v1beta2
kind: EtcdCluster
metadata:
  name: example
  annotations:
    etcd.database.coreos.com/scope: clusterwide
spec:
  size: 3
  version: 3.2.13
END
```
Note that version 3.2.13 will be created with a cluster size of 3 instances (each instance in a pod).

As the Etcd cluster is being created, observer the steps taken in the upper terminal: 

```execute
oc get events -w | grep /example
```
You should be able to observe the steps taken to create the Etcd Cluster.  E.g. ``New member example-xxxyyyzzz added to cluster``.

After all three pods of the Etcd cluster have been created (see them in the lower terminal), stop the command in the upper terminal:

```execute
<ctrl+c>
```

Now, view the Custom Resource:

```execute
oc get EtcdCluster 
```

View the details about the Custom Resource:

```execute
oc describe EtcdCluster example
```

To access the Etcd Cluster, launch a separate pod containing the ``etcdctl`` command:


```execute
oc run --rm -it testclient --image quay.io/coreos/etcd --restart=Never -- /bin/sh
```
A ``$ `` command prompt should appear.

Inside the pod, run the following commands:

Set the Etcd version to use:

```execute
export ETCDCTL_API=3
```

Using the ``etcdctl`` command, add a value to the Etcd cluster:

```execute
etcdctl --endpoints http://example-client:2379 put foo bar
```

Read a value from the Etcd cluster:

```execute
etcdctl --endpoints http://example-client:2379 get foo
```

Delete a value from the Etcd cluster:

```execute
etcdctl --endpoints http://example-client:2379 del foo
```

Try to read a value that does not exist from the Etcd cluster:

```execute
etcdctl --endpoints http://example-client:2379 get foo
```

Exit from the etcdctl pod:

```execute
exit
```

Delete one instance of the Etcd cluster:

```execute
oc delete pod `oc get pod | grep example | awk '{print $1}' | tail -1`
```

In the bottom terminal, the Etcd cluster is repaired by the Etcd Operator.  This is similar to what a Kubernetes ``deployment`` controller would do, 
but there is a lot more to it.
The Etcd operator needs to create a new Etcd cluster member, add it back into the Etcd cluster and initialize (re-distribute) it with the data that already exists in the Etcd Cluster.

You will see that the Etcd Operator restored the Etcd Cluster back to how it was.

It is also possible to expand the Etcd Cluster by increasing the size:

```execute
oc patch EtcdCluster example --type merge -p '{"spec":{"size":5}}'
```

Observe how the Etcd Cluster is scaled out.

Now, to remove the Etcd Cluster, all that's needed is to remove the custom resource. 

```execute
oc delete EtcdCluster example
```

Now, clean up:

```execute-2
<ctrl+c>
```

In this exercise you were able to deploy an etcd cluster, connect to it, scale it and watch it self-heal.  

---
That's the end of this exercise.

