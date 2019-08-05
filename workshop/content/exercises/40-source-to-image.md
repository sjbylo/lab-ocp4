In this lab you will use ``Source to Image`` to build and launch the voting application on OpenShift.

_From the very beginning, one of the main objectives of the OpenShift project was to make it really easy for developers to get code running on the platform._

"oc new-app" is the command that initializes an application in various ways on OpenShift. 
You will use it to get your source code running on OpenShift. 

Source 2 Image (s2i) does the following: 

1. Launches a container from a "builder image" of the matching runtime.  In this case that's a python 2.7 builder image.
1. Executes a build of the application in the running builder container.
1. After a successful build, s2i commits a new image containing the built application and pushes it into the internal registry of OpenShift. 
1. The container is launched because a new image has been created.  If the container is already running from a previous build, the container will be re-deployed. 

Using the following ``--dry-run`` option, you can first see what the "new-app" command will do. 


 - ``Note: Normally the "new-app" command would automatically select a matching builder image based on the source
code but since our code specifically requires Python version 2.7 to function properly we explicitly provide the name
and version of the builder image we want to use (python:2.7).``

Run the following command in the lower terminal so we can view the running containers/pods during the rest of the labs:

```execute-2
watch "oc get pods | grep -e ^db- -e ^vote-app- | grep -v ' Completed '"
```

This command will run for most of the labs and should now show ``No resources found`` since we haven't built anything yet. 

# Execute the Source 2 Image build process 

Now run the ``new-app`` command and see what it will do:

```execute
oc new-app python:2.7~. --name vote-app --dry-run
```

The above command does the following:

1. looks into the current working directory ".", detects python source code and determines its associated GitHub repository. 
1. creates a build object called a ``build configuration`` (BC).  The build configuration knows:
   1. the location of the repository which holds the ``python builder image`` 
   1. where to fetch the source code from, e.g. the GitHub repository
   1. knows the name of the output image which will be pushed into the internal container registry (``vote-app``)
1. creates an ``image streams`` (IS) (a.k.a. OpenShift image objects) to track the builder and the final application image
   1. these image streams are able to detect when images are updated and trigger a rebuild or a re-deployment of the application  
1. creates a deployment object called a ``deployment configuration`` (DC).  The deployment configuration knows:
   1. how to re-deploy the application should the image be updated
1. creates a ``service object`` to enable discovery and access to one or more running application containers. 


If there are no warnings or errors and all looks well, execute the command without the ``--dry-run`` option:

```execute
oc new-app python:2.7~. --name vote-app 
```

This command will have listed out all the OpenShift objects that were created.

<!--
- ``Note: Should the build configuration already exists from a previous invocation, start the build again with the following command:``

```execute
oc start-build vote-app 
```
-->

In the lower terminal window you can see the build container running.  That's the one that's building your vote application.  You should see ``vote-app-1-build   1/1     Running``. 

You can view the build process in the console and also on the command line, like this:

```execute 
oc logs bc/vote-app --follow 
```

To view the build log in the console, click on the build (``vote-app-1``) and then on the ``Logs`` tab:

[View the build](%console_url%/k8s/ns/%project_namespace%/builds)


Wait for the build to finish.  Note, this can take a few minutes, especially the ``Copying blob...`` and the ``Storing signatures`` operations can be slow. 

You will see the following amongst the output:

```
...
Cloning "https://github.com/johnsmith/flask-vote-app.git" ...
...
STEP 8: RUN /usr/libexec/s2i/assemble
...
STEP 10: COMMIT temp.builder.openshift.io/...
...
Successfully pushed ...
Push successful
```

What happens during the build?

1. the source code is cloned.
1. the python builder image is launched and the code copied into it.
1. the s2i ``assemble script`` is executed.  It knows how to build a python application.
1. the python dependencies are installed 
1. the running container is committed and a new image is created
1. the image is then pushed into OpenShift's internal container registry

After the build the image is automatically launched and a pod created.

In the lower terminal window you can see the build container has completed ``vote-app-1-build`` and a new application container is starting ``vote-app-1-xxyyzz``.

You can also run the following command to view the pods running in your project: 

```execute
oc get pods
```

You should see something similar to this:

```
NAME               READY     STATUS      RESTARTS   AGE
vote-app-1-build   0/1       Completed   0          4m
vote-app-1-deploy  0/1       Running     0          3m
vote-app-1-gxq5k   1/1       Running     0          30s
```

1. The vote-app-1-build pod has completed what it was doing, namely building the python application. 
1. The vote-app-1-deploy pod was launched to deploy the vote application pod.
1. Now the vote-app-1-gxq5k pod has started.

Wait for the build to complete (``Push successful``).

Now take a look in the console to view the running application. There should be a running pod called ``vote-app-1-xxyyzz`` Also, try opening a terminal window _from within the console_ to explore inside the running container.  Run ``ps -ef`` inside the running container to see the running python process: 

[View the console](%console_url%/k8s/ns/%project_namespace%/pods) 

You should see something like this:

```
(app-root)sh-4.2$ ps -ef
UID         PID   PPID  C STIME TTY          TIME CMD
1002280+      1      0  0 08:24 ?        00:00:00 python app.py
1002280+     34      0  0 08:24 pts/0    00:00:00 sh
1002280+     64      0  0 08:27 pts/1    00:00:00 sh
1002280+     88     64  0 08:27 pts/1    00:00:00 ps -ef
(app-root)sh-4.2$
```

The status of your project can be seen here:

[Project Status](%console_url%/overview/ns/%project_namespace%) 

Here you can see the Deployment Configuration object which helps take care of the application life-cycle. 

# Expose the application for testing 

By default, the application is not accessible from outside of OpenShift. Now, expose the application to the external network so it can be tested:

```execute
oc expose svc vote-app
```

The above command  creates a ``route`` object.  An OpenShift Container Platform route exposes a service at a host name, like www.example.com, so that external clients can reach it by name. 

Check the route object:

```execute 
oc get route
```

# Test the application 

To check the application is working you can either use curl or load the URL into your browser.

Use curl to check the app is working:

```execute 
curl http://vote-app-%project_namespace%.%cluster_subdomain%/ 
```

or use another way which checks for the expected output:

```execute 
curl -s http://vote-app-%project_namespace%.%cluster_subdomain%/ | grep "<title>"
```

You should see the following output which means the application is working:

```
    <title>Favourite Linux distribution</title>
```

The application can be further tested using a helper-script.

Post a few random votes to the application using the help-script:

```execute 
test-vote-app http://vote-app-%project_namespace%.%cluster_subdomain%/vote.html
```

To view the results use the following command. You should see the totals of all the voting options:

```execute 
curl -s http://vote-app-%project_namespace%.%cluster_subdomain%/results.html | grep "data: \["
```

You should see something like the following, showing all the cast votes: 

```
  data: [ "3",  "3",  "2",  "0",  "1",  "5",  "1",  "3",  "2", ],

```

Or, view the results page in a browser:

[View Results page](http://vote-app-%project_namespace%.%cluster_subdomain%/results.html)


Note that:

 - if the message ``Application is not available`` is displayed, this means the application is not running yet or the build has failed.
 - your neighbour should be able to access your application and submit a vote.  Note that only one vote per browser is allowed.
 - by default, the application uses a built-in database to store the vote data.  In later labs we will configure the application to use an external MySQL database.
 

Finally, take a loo kat the resource utilization in the Console: 

* [Status](%console_url%/overview/ns/%project_namespace%)

Click on the ``Dashboard`` button to see your resource usage in your project.

# Create a Webhook (optional) 

``Optionally``, if you are interested to have the build execute automatically on every code change, configure a webhook in GitHub which will trigger the s2i build on every code commit and push. 

Use the following helper script to view the instructions and values that you will need to configure the webhook. 

```execute
getwebhook vote-app %cluster_subdomain%
```

 - ``Important: Follow the instructions displayed by the above command.``

Log into GitHub, navigate to the ``flask-vote-app`` repository, click on ``Settings`` and then on ``Webhooks``. 

Click on the "``Add Webhook``" button and fill in the form using the following information:

- Payload URL: ``see the helper script output``
- Content type: application/json
- Secret: ``see the helper script output``
- SSL verification: Disabled 

Leave the other settings as they are.

Finally, click on the "``Add Webhook``" button.

GitHub will immediately test the webhook and show the result on the next page.  If you see a ``tick`` next to the webhook, that means it's working. 

<!-- This next part is removed as it's also in the next lab

Now, when you make a change to the code, commit and push it, a fresh build will be triggered automatically. 

The following command makes a superficial change to the source code, commits and pushes the change to GitHub.  This should trigger a re-build and a
re-deployment of the application.

```execute
echo >> README.md && \
git commit -m "update" . && \
git push
```

Watch the build take place again, see a new image being created and the application being re-deployed. 
-->

---
That is the end of the lab. 

In this lab you build the application and tested it. 

---
## Example output of a full application build:

```
$ oc logs bc/vote-app
Cloning "https://github.com/sjbylo3/flask-vote-app.git" ...
	Commit:	23d4bdeec2449deb1532280cce6be54b6f0200f0 (update)
	Author:	Your Name <you@example.com>
	Date:	Wed Jul 3 09:35:55 2019 +0000
Caching blobs under "/var/cache/blobs".
Getting image source signatures
Copying blob sha256:db1d55616933198cd32cb3a3a658a903a9205c733af15ca6423268d83a2a5840
...
Writing manifest to image destination
Storing signatures
07822e6843338f8ad388f1f34294082de46f7e897c6a743d60dde1e3af55be71
Generating dockerfile with builder image image-registry.openshift-image-registry.svc:5000/openshift/python@sha256:b604de44d1d298873ba1620e2941536a4ec2c836b43eafdcbcd61132bd446d70
STEP 1: FROM image-registry.openshift-image-registry.svc:5000/openshift/python@sha256:b604de44d1d298873ba1620e2941536a4ec2c836b43eafdcbcd61132bd446d70
STEP 2: LABEL "io.openshift.build.image"="image-registry.openshift-image-registry.svc:5000/openshift/python@sha256:b604de44d1d298873ba1620e2941536a4ec2c836b43eafdcbcd61132bd446d70" "io.openshift.build.commit.author"="Your Name <you@example.com>" "io.openshift.build.commit.date"="Wed Jul 3 09:35:55 2019 +0000" "io.openshift.build.commit.id"="23d4bdeec2449deb1532280cce6be54b6f0200f0" "io.openshift.build.commit.ref"="master" "io.openshift.build.commit.message"="update" "io.openshift.build.source-location"="https://github.com/sjbylo3/flask-vote-app.git"
STEP 3: ENV OPENSHIFT_BUILD_NAME="vote-app-6" OPENSHIFT_BUILD_NAMESPACE="lab-ocp4" OPENSHIFT_BUILD_SOURCE="https://github.com/sjbylo3/flask-vote-app.git" OPENSHIFT_BUILD_REFERENCE="master" OPENSHIFT_BUILD_COMMIT="23d4bdeec2449deb1532280cce6be54b6f0200f0"
STEP 4: USER root
STEP 5: COPY upload/src /tmp/src
STEP 6: RUN chown -R 1001:0 /tmp/src
STEP 7: USER 1001
STEP 8: RUN /usr/libexec/s2i/assemble
---> Installing application source ...
---> Installing dependencies ...
You are using pip version 7.1.0, however version 19.1.1 is available.
You should consider upgrading via the 'pip install --upgrade pip' command.
Collecting flask (from -r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/9a/74/670ae9737d14114753b8c8fdf2e8bd212a05d3b361ab15b44937dfd40985/Flask-1.0.3-py2.py3-none-any.whl (92kB)
Collecting flask-sqlalchemy (from -r requirements.txt (line 2))
  Downloading https://files.pythonhosted.org/packages/08/ca/582442cad71504a1514a2f053006c8bb128844133d6076a4df17117545fa/Flask_SQLAlchemy-2.4.0-py2.py3-none-any.whl
Collecting mysql-python (from -r requirements.txt (line 3))
  Downloading https://files.pythonhosted.org/packages/a5/e9/51b544da85a36a68debe7a7091f068d802fc515a3a202652828c73453cad/MySQL-python-1.2.5.zip (108kB)
Collecting itsdangerous>=0.24 (from flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/76/ae/44b03b253d6fade317f32c24d100b3b35c2239807046a4c953c7b89fa49e/itsdangerous-1.1.0-py2.py3-none-any.whl
Collecting Werkzeug>=0.14 (from flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/9f/57/92a497e38161ce40606c27a86759c6b92dd34fcdb33f64171ec559257c02/Werkzeug-0.15.4-py2.py3-none-any.whl (327kB)
Collecting Jinja2>=2.10 (from flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/1d/e7/fd8b501e7a6dfe492a433deb7b9d833d39ca74916fa8bc63dd1a4947a671/Jinja2-2.10.1-py2.py3-none-any.whl (124kB)
Collecting click>=5.1 (from flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/fa/37/45185cb5abbc30d7257104c434fe0b07e5a195a6847506c074527aa599ec/Click-7.0-py2.py3-none-any.whl (81kB)
Collecting SQLAlchemy>=0.8.0 (from flask-sqlalchemy->-r requirements.txt (line 2))
  Downloading https://files.pythonhosted.org/packages/62/3c/9dda60fd99dbdcbc6312c799a3ec9a261f95bc12f2874a35818f04db2dd9/SQLAlchemy-1.3.5.tar.gz (5.9MB)
Collecting MarkupSafe>=0.23 (from Jinja2>=2.10->flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/b9/2e/64db92e53b86efccfaea71321f597fa2e1b2bd3853d8ce658568f7a13094/MarkupSafe-1.1.1.tar.gz
Installing collected packages: itsdangerous, Werkzeug, MarkupSafe, Jinja2, click, flask, SQLAlchemy, flask-sqlalchemy, mysql-python
  Running setup.py install for MarkupSafe
  Running setup.py install for SQLAlchemy
  Running setup.py install for mysql-python
Successfully installed Jinja2-2.10.1 MarkupSafe-1.1.1 SQLAlchemy-1.3.5 Werkzeug-0.15.4 click-7.0 flask-1.0.3 flask-sqlalchemy-2.4.0 itsdangerous-1.1.0 mysql-python-1.2.5
STEP 9: CMD /usr/libexec/s2i/run
STEP 10: COMMIT temp.builder.openshift.io/lab-ocp4/vote-app-6:08b9efd8
Getting image source signatures
Copying blob sha256:8783de338a118d308a5f8e00576afc318fac3a8a35767d95948493915cc249a8
...
Writing manifest to image destination
Storing signatures
--> 4efd91078c869feb60bcdbae4b6683cb12984fb20d4dc1bf208f1d7684375860

Pushing image image-registry.openshift-image-registry.svc:5000/lab-ocp4/vote-app:latest ...
Getting image source signatures
Copying blob sha256:db1d55616933198cd32cb3a3a658a903a9205c733af15ca6423268d83a2a5840
...
Writing manifest to image destination
Storing signatures
Successfully pushed //image-registry.openshift-image-registry.svc:5000/lab-ocp4/vote-app:latest@sha256:cf182b356492d25b9a5af1e014564bbb52691c530e2a8e8928ce70898a0596f5
Push successful
```

