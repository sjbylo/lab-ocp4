---
Title: Get Source Code Running In Openshift
PrevPage: 02-accessing-openshift
NextPage: 04-rest-of-workshop
---

## Lab 2

Is this lab ... you will fetch the source code that you will use for the rest of the labs.  You will make a copy (fork) of a github source code repository and then, using the source code, build and deploy the source code to OpenShift. 

_From the very beginning, one of the main goals of the OpenShift project was to make it really easy for developers to get their code up and running...._

Fork a GitHub source code repository. [this can be all scripted for the participant]. 

```execute
git clone https://github.com/sjbylo/flask-vote-app.git
```

```execute
cd flask-vote-app
```

Enter your GitHub username and then your password at the prompt:

```execute 
hub fork
```

(note that 'hub' is a CLI for github API which we can pre-install) 
(https://hub.github.com/)

This will display your new repository name... 

```execute
cd ..
```

```
git clone <your new repository name>
cd <your new repository>
```

Build a container application from source code using S2i... 

``oc new-app . python:2.7 --dry-run`` # Remove the Dockerfile from repository?

Check the output, explain what it does... 

Run for real now...

``oc new-app . python:2.7``  # Remove the Dockerfile from repository?

Check the build output ...

``oc logs -f bc/flask-vote-app``

The python builder image will be ... 

You will see the following in the output:

```
...
STEP 8: RUN /usr/libexec/s2i/assemble
...
STEP 10: COMMIT temp.builder.openshift.io/...
...
Successfully pushed ...
```

Explain the above. 

Get access to the running application....

Explain route... 

Create and check a route...

```execute 
oc get svc
```

```execute 
oc expose svc flask-vote-app
```

```execute 
oc get route
```

To check the application is working you can either use curl or load the URL into your browser.

Use curl to check the app is working

```execute 
curl http://flask-vote-app-%project_namespace%.%cluster_subdomain%/ 
```

You should see...

Test the application...

```execute
curl http://flask-vote-app-%project_namespace%.%cluster_subdomain%/ 

##VOTE_APP_ROUTE=$(oc get route vote-app --template='{{.spec.host}}'); echo $VOTE_APP_ROUTE
##curl $VOTE_APP_ROUTE 
```

Optionally: If you are interested ... configure a webhook to trigger the s2i build on code change. 

<get instructions fot this>


