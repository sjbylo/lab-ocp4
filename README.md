# Labs

## Preparation 

We will set up a full 4.1 cluster for this lab. 

Looking into using one of the following methods to run the workshop:
1. Ask participants to log into a linux ec2 instance where we can set up all tools needed, e.g. oc, git etc
1. Use this new workshop tool by Graham D... which looks to become very papular, also with the BU.  https://github.com/openshift-labs/workshop-dashboard/
1. Use the older "workshopper" CMS.  For this, need to install oc on laptop, so not preferred. 

## Lab 1

**Note: Following is skeleton of labs...**

In this lab you will access the workshop environment, authenticate OpenShift 4 and familiarize yourself with the command line and also the web console. 

Commands: 

``oc whoami``

``oc version``

``oc whoami --show-server``

``oc projects``

Fetch the console URL

``oc whoami --show-console``

Open the console in a browser and log in

Guide them to view cluster status, catalog, operator hub, logs, metrics, other great stuff etc etc...

## Lab 2

Is this lab ... you will fetch the source code that you will use for the rest of the labs.  You will make a copy (fork) of a github source code repository and then, using the source code, build and deploy the source code to OpenShift. 

_From the very beginning, one of the main goals of the OpenShift project was to make it really easy for developers to get their code up and running...._

Fork a GitHub source code repository. [this can be all scripted for the participant]. 

```
git clone https://github.com/sjbylo/flask-vote-app.git
cd flask-vote-app
#rm -f  ~/.config/hub
hub fork
```
(note that 'hub' is a CLI for github API which we can pre-install) 
(https://hub.github.com/)

This will display your new repository name... 

```
cd ..
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

```
oc get svc

oc expose svc flask-vote-app

oc get route
```

To check the application is working you can either use curl or load the URL into your browser.

Use curl to check the app is working

```
curl <your route>
```
You should see...

Test the application...

```
VOTE_APP_ROUTE=$(oc get route vote-app --template='{{.spec.host}}'); echo $VOTE_APP_ROUTE

curl $VOTE_APP_ROUTE 
```

Optionally: If you are interested ... configure a webhook to trigger the s2i build on code change. 

<get instructions fot this>

## Lab 3

In this lab ... Make a change in the source code and rebuild/redeploy the container... 
Trigger the build, if needed. 

Guide how to make a change in the source code and commit the change.  Using github it's easy.  Follow instructions..... 

If you set up the webhook ...
If not, trigger a new build ... 

```
oc start-build flask-vote-app --follow --wait
```

What you should see ... 

Check the change is now deployed.... 

## Lab 4

_Note, for this lab, could use a DB operator, although I can't find one that works, yet._

In this lab ... you will launch a database and configure your application to use the database..... 

Launch a database and connect the application to it...

Run this to start MySQL container:

```
oc new-app --name db -e MYSQL_USER=user -e MYSQL_PASSWORD=password -e MYSQL_DATABASE=vote mysql:5.7
```

Connect the application to the database....

Explain what will happen... 

```
oc set env dc vote-app DB_HOST=db DB_PORT=3306 DB_NAME=vote DB_USER=user DB_PASS=password
DB_TYPE=mysql
```

Explain how that worked... 

## Lab 5

In this lab you will scale the application... 

```
oc scale --replicas=3 dc/vote-app
oc get pods
```

Test the application.... 

```
VOTE_APP_ROUTE=$(oc get route vote-app --template='{{.spec.host}}'); echo $VOTE_APP_ROUTE

curl $VOTE_APP_ROUTE 
```


## Lab 6

Note: For this lab the "aws operator" must be installed first by a cluster admin user. 

In this lab you will provision a XXX in AWS and then configure your application to use it.... 

Using the AWS Operator, provision an aws service (e.g. SQS or dynamo DB).  Connect the aws service to the application and test it. 

Hope to use the same app as above, or use a separate app.



