---
Title: Get Source Code Running In Openshift
PrevPage: 02-accessing-openshift
NextPage: 04-rest-of-workshop
---

## Lab 2

Is this lab ... you will fetch the source code that you will use for the rest of the labs.  You will make a copy (fork) of a github source code repository and then, using the source code, build and deploy the source code to OpenShift. 

_From the very beginning, one of the main goals of the OpenShift project was to make it really easy for developers to get code running...._

# Use Source 2 Image to build and launch the application on OpenShift 

In this lab you will build your application in a container running on OpenShift itself. This is done using Source 2 Image (s2i) 
which does the following:

1. Launches a container from a "builder image" of the matching runtime.  In this case that's a python 2.7 builder image.
1. Executes a build of the application in the running builder container.
1. After a successful build, s2i commits a new image containing the application and pushes it into the internal registry of OpenShift. 
1. The container is launched (or updated) because the image has been created (or updated). 

First, set up your own GitHub source code repository using your own GitHub account.  If you don't have an account, first sign up for one at http://github.com/ and remember the username and password for the next step. 

Clone the application source code from the public GitHub repository: 

```execute
git clone https://github.com/sjbylo/flask-vote-app.git
```

Change into the new directory:

```execute
cd flask-vote-app
```

This next step will fork the GitHub repository into your account called flask-vote-app.

Enter your GitHub username and then your password at the prompt:

```execute 
fork-repo 
```

This will fork the repository display your new repository name.

You should now have your own GitHub repository containing the example source code. 

Run this command to verify the repository belongs to you.  You shoukld see your GitHub username.

```execute
git remote -v
```

---
## Launch the application using s2i

"oc new-app" is the command that initializes an application on OpenShift. 
You will use it to get your source code running on the OpenShift platform. 

Using the following "dry-run" option, you can first see what the "new-app" command will do. 

The below command does the following:
1. looks into the current working directory ".", detects python source code and determines its related GitHub repository. 
1. creates a build object called a build configuration (BC).  The build configuration knows:
   1. the location of the python builder image repository.
   1. where to fetch the source code from, e.g. the GitHub repository. 
   1. knows the name of the output image which will be pushed into the internal container registry. 
1. creates image streams (IS) (a.k.a. Kubernetes image objects) to track the builder and the final application image.
1. these image streams are able to track when images are updated and trigger a rebuild or a re-deployment of the application.  
1. creates a deployment object called a deployment configuration (DC).  The deployment configuration knows:
   1. how to redeploy the application should the image be updated. 
1. creates a service object to enable discovery and access to one or more running application containers. 

``
Note: Normally the "new-app" command would automatically select a matching builder image (e.g. python) based on the source code but since our code specifically needs version 2.7 we explicitly provide the name and version of the builder image we want to use (python:2.7).
``

Run the command and see what is will do anc compare this to the explanation above. 

```execute
oc new-app python:2.7~. --name vote-app --dry-run
```

If all looks well (no warning or errors), execute the command: 

```execute
oc new-app python:2.7~. --name vote-app 
```

You can view the build process in the console and also on the command line, like this:


```execute 
oc logs bc/vote-app --follow 
```

Note, how the source code is first cloned, the python dependencies are installed and then a
new image is committed/pushed into the internal container registry. 

After the build the image will be automatically launched.

Check it out:

```execute
oc get po
```

You should see sometihng similar to this:

```
NAME               READY     STATUS      RESTARTS   AGE
vote-app-1-build   0/1       Completed   0          10m
vote-app-1-gxq5k   1/1       Running     0          10m
```

The vote-app-1-build pod has completed what it was doing, namely building the python application. 
Now the vote-app-1-gxq5k pod has started.

If not already, expose the application to the external network:

```execute
oc expose svc vote-app
```

You will see the following amongst the output:

```
...
STEP 8: RUN /usr/libexec/s2i/assemble
...
STEP 10: COMMIT temp.builder.openshift.io/...
...
Successfully pushed ...
Push successful
```

FIXME: Explain the above. 

To get access to the running application we need to expose it to the outside world. 

FIXME: Explain route... 

Create and check a route...

```execute 
oc get svc
```

```execute 
oc expose svc vote-app
```

```execute 
oc get route
```

To check the application is working you can either use curl or load the URL into your browser.

Use curl to check the app is working

```execute 
curl http://vote-app-%project_namespace%.%cluster_subdomain%/ 
```

You should see... FIXME

Test the application in a browser with the following URL:

http://vote-app-%project_namespace%.%cluster_subdomain%/ 

Optionally: If you are interested ... configure a webhook in GitHub to trigger the s2i build on code change. 

FIXME: get instructions for this 


