In this lab you will learn how to scale the application, manage the deployment process and execute a blue/green deployment. 

 - Note: ``This lab is optional.`` 

Scale the application up to 3 containers/pods: 

```execute
oc scale --replicas=3 dc/vote-app
```

See the scaling action in the [console](%console_url%/k8s/ns/%project_namespace%/pods). 

```execute
oc get pods
```

Test the application to check it still works properly having been scaled out to 3 containers.  

```execute 
curl -s http://vote-app-%project_namespace%.%cluster_subdomain%/ | grep "<title>"
```

 - Note that all the `state` of the application is stored in the database. Each container/pod is therefore `stateless` and can be freely stopped and started, as needed. 

See in other window ... 

First stop the ``watch`` command running in the lower terminal:

```execute-2
<ctrl+c>
```

Execute this command which will watch for rollout history:

```execute-2
watch oc rollout history dc vote-app
```

Try ... FIXME: Explain deployments, rolling deployments etc ... 

Rollout a the application again: 

```execute
oc rollout latest vote-app
```

Rollback (undo) the deployment: 

```execute
oc rollout undo dc vote-app
```

Rollout the application again: 


```execute
oc rollout latest vote-app
```

During the rollout, cancel it: 

```execute
oc rollout cancel dc vote-app
```
Rollback (undo) the deployment: 


```execute
oc rollout undo dc vote-app --to-revision=2
```

FIXME: blue / green deployment by adding a 2nd version of the app.... 

---
That's the end of this lab.

Please move onto the next lab.  