In this lab you will learn how to manage the deployment process. 

 - Note: ``This lab is optional.`` 

Ensure the application is scaled to 3 containers/pods: 

```execute
oc scale --replicas=3 dc/vote-app
```

Throughout this lab, you can see the scaling/rollout action in the [console](%console_url%/k8s/ns/%project_namespace%/pods). 

```execute
oc get pods
```

Test the application to check it's still working as expected: 

```execute 
curl -s http://vote-app-%project_namespace%.%cluster_subdomain%/ | grep "<title>"
```

See in other window ... 

First stop the ``watch`` command running in the lower terminal:

```execute-2
<ctrl+c>
```

Execute this command in the lower terminal which will watch ``rollout history``:

```execute-2
watch oc rollout history dc vote-app
```

DeploymentsConfigs (Kubernetes Objects) provide fine-grained management over common user applications. If you wish, please read more about [OpenShift Deployment Configs](https://docs.openshift.com/container-platform/3.11/dev_guide/deployments/how_deployments_work.html).  Let's try it out. 

Roll out the application again: 

```execute
oc rollout latest vote-app
```

This will deploy the ``same version`` of the application again. 
Also, this will create a new deployment ``revision``. Look into the lower terminal to see the new revision. 

You should see:

```
...   Running         manual change
```

Wait for the application to be rolled out and ``Running`` again. 

Rollback (undo) the deployment: 

```execute
oc rollout undo dc vote-app
```

This will roll back the application to the previous version. 

Rollout the application again: 

```execute
oc rollout latest vote-app
```

If a rollout is not going as planned you can cancel it.  Try that now:

```execute
oc rollout cancel dc vote-app
```

Rollback (undo) the deployment to one of the earlier versions of the application, revision 2: 

```execute
oc rollout undo dc vote-app --to-revision=2
```

You should see a new rollout is ``Running``.  

Wait for the application to be rolled back and ``Running`` again. Check with this command:

```execute
oc get pod
```

If you remember, the 2nd ever deployment of the application was  using the MySQL in the containerized database.  If you look at the application log output you should now see it using the containerized database again. 

Look at the log output to check which database it's using:

```execute
oc logs dc/vote-app 
```

You should see the following amongst the log output: 

```
Connect to : mysql://user:password@db:3306/vote
```

Note, if you don't see the expected output, wait for the application to be ``Running`` again. 

If you are interested, try to rollback to revision 1 and check that the application is using the internal sqlite built-in database: 

```execute
oc rollout undo dc vote-app --to-revision=1
```

Wait for the rollout to finish and check the output log again:

```execute
oc logs dc/vote-app 
```

You should see the following amongst the log output: 

```
Connect to : sqlite:////opt/app-root/src/data/app.db
```

In this lab you were able to easily rollout new versions of the application and also rollback to older versions. 

---
That's the end of this lab.

Please move onto the next lab.  