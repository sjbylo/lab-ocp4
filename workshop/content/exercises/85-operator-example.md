In this exercise you will learn about the Etcd Operator

* [Installed Operators](%console_url%/ns/%project_namespace%/clusterserviceversions)
* [Installed Operators](%console_url%/clusterserviceversions/ns/%project_namespace%)
* [Developer Catalog](%console_url%/catalog/ns/%project_namespace%)

https://lab-ocp4-labs.apps.cluster-scbank-4cc1.scbank-4cc1.example.opentlc.com/user/5z00g/console/k8s/ns/default/clusterserviceversions

Check what's running:

```execute
oc get po
```

Clean up:

```execute
oc delete all --all 
```

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

View the Custom Resource:

```execute
oc get EtcdCluster 
```

View the details about the Custom Resource:

```execute
oc describe EtcdCluster example
```

```execute
oc run --rm -it testclient --image quay.io/coreos/etcd --restart=Never -- /bin/sh
```

Inside the pod, run the following commands.

```execute
export ETCDCTL_API=3
```

Add a value to the Etcd cluster:

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

Read a value from the Etcd cluster:

```execute
etcdctl --endpoints http://example-client:2379 get foo
```

Watch the Etcd cluster pods in the bottom terminal:

```execute-2
watch "oc get pods | grep example | grep -v ' Completed '"
```

Delete one instance of the cluster:

```execute
oc delete `oc get po | grep example | awk '{print $1}' | tail -1`
```

In the bottom terminal, the cluster is repaired by the Etcd Operator.  This is similar to what the "deployment" controller would do, but there is a lot more to it.
The Etcd operator needs to create a new Etcd cluster member, add it back into the cluster and initialize (distribute) it with the existing data.

In this exercise you were able to deploy an etcd cluster, connect to it and watch it self-heal. 

---
That's the end of this exercise.

