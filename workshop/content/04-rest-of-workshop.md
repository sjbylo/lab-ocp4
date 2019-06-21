---
Title: Rest Of Workshop
PrevPage: 03-get-source-code-running-in-openshift
NextPage: 20-end-of-the-workshop
---

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




