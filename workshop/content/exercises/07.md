In this lab you will learn how to manage your application. 

... scale the application, deploy a new version and execute a blue/green deployment. 

FIXME: complete this lab!

 - Note: ``This lab is optional.`` 

```execute
oc scale --replicas=3 dc/vote-app
```

```execute
oc get pods
```

Test the application.... 

```execute 
curl -s http://vote-app-%project_namespace%.%cluster_subdomain%/ | grep "<title>"
```

See in other window ... 

First stop the ``watch`` command running in the lower terminal:

```execute-2
<ctrl+c>
```

Execute this command which will watch for rollout history:

```execute-2
watch oc rollout history dc vote-app
```

Try ... FIXME: Explain..

```execute
oc rollout latest vote-app
```

```execute
oc rollout undo dc vote-app
```

```execute
oc rollout latest vote-app
```

```execute
oc rollout cancel dc vote-app
```

```execute
oc rollout undo dc vote-app --to-revision=2
```

Try also git push (using trigger) 

FIXME: blue / green deployment by adding a 2nd version of the app.... 

