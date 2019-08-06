In this lab you will launch a database ``in a container`` and configure your application to use the database instead of the default built-in database.

First, ensure only one replica of the application is running:

```execute
oc scale dc vote-app --replicas=1
```

# Launch the database 

Launch a MySQL database and connect the application to it.  MySQL is a freely available open source Relational Database Management System (RDBMS) that uses Structured Query Language (SQL). 

Run this to start a MySQL container:

```execute
oc new-app --name db mysql:5.7 \
   -e MYSQL_USER=user \
   -e MYSQL_PASSWORD=password \
   -e MYSQL_DATABASE=vote 
```

MySQL will be started and configured with a database called ``vote`` and with ``user`` and `password` credentials, as stated in the above command parameters. 

Take a look at the log output:

```execute
oc logs dc/db
```

It will take about 30 seconds for the database to be running.  You will see `ready for connections` in the log output.  If not, try the above ``oc logs`` command again. 

Once the database is up and running, verify that by checking if the ``vote`` database exists:

```execute
mysql -h db.%project_namespace%.svc -u user -ppassword -D vote -e "show databases"
```

- You should see the ``vote`` database in the list.  If not, wait for the database to come up and/or check the above and try again. 

## Connect the application to the database 

At this point, the application is unaware of the existence of the MySQL database!  You need to re-configure the application to use the new database. 
To do that we will change the vote application's environment variables and re-launch the pod.  The vote application looks for the existence of the environment variables at startup and uses them to configure itself.  If database credentials are defined the application connects to the database and provisions the needed tables and data. 

Connect the application to the database:

```execute
oc set env dc vote-app \
   ENDPOINT_ADDRESS=db \
   PORT=3306 \
   DB_NAME=vote \
   MASTER_USERNAME=user \
   MASTER_PASSWORD=password \
   DB_TYPE=mysql
```

The above command sets the environment variables `as stated in the arguments`. The deployment configuration restarts the pod automatically because of the configuration change.

Check that the application is running properly and was able to connect to the database:

```execute
oc logs dc/vote-app 
```

You should see the following in the output, showing the database credentials used.  If not, wait and try the ``oc logs`` command again.

```
---> Running application from Python script (app.py) ...
Connect to : mysql://user:password@db:3306/vote
...
```

Check that the database is now populated with the vote application tables:

<!--
POD=`oc get pods --selector app=workspace -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}'`; echo $POD

kubectl get pods --field-selector=status.phase=Running -o name
-->

```execute
mysql -h db.%project_namespace%.svc -u user -ppassword -D vote -e "show tables"
```

You should see the  ``poll`` and ``options`` tables. 

<!--
```
POD=`oc get pods --selector app=workspace -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}'`; echo $POD
```
-->

# Test the application 

Post a few random votes to the application using the help-script:

```execute 
test-vote-app http://vote-app-%project_namespace%.%cluster_subdomain%/vote.html
```

To view the results use the following command. You should see the totals of all the voting options:

```execute 
curl -s http://vote-app-%project_namespace%.%cluster_subdomain%/results.html | grep "data: \["
```

After testing the application and casting one or more votes, check the votes in the database: 


```execute
mysql -h db.%project_namespace%.svc -u user -ppassword -D vote -e 'select * from `option`;'
```

View the containers/pods in the console:

* [View the Pods](%console_url%/k8s/ns/%project_namespace%/pods) 

Open the vote application in a browser: 

* [Open the Application](http://vote-app-%project_namespace%.%cluster_subdomain%/) 



Now, the application is no longer dependent on the built-in database and can freely scale out - `add containers` - as needed. 

Go to the console and scale the application pods from 1 to 3 (please do not scale to more than 3). 

* [View the Pods](%console_url%/k8s/ns/%project_namespace%/pods) 

You can also use the following command:

```execute
oc scale dc vote-app --replicas=3
```

After 30-60 seconds, you should see the output in the lower window, similar to this:

```
vote-app-3-52kqp    1/1     Running     0          17s
vote-app-3-nb5fk    1/1     Running     0          17s
vote-app-3-p2j4w    1/1     Running     0          7m45s
```

Check the application is still working as expected.  Data should not be lost: 

[Open the Vote Application](http://vote-app-%project_namespace%.%cluster_subdomain%/) 

 - ``Please remember to scale the vote application back down to 1 or use the following command:``

```execute
oc scale dc vote-app --replicas=1
```

---
That's the end of this lab.

In this lab you have launched a database for testing purposes and connected the application to it.  

In the next lab you will configure the cloud based database. 


