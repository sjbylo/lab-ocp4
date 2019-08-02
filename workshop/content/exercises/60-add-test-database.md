In this lab you will launch a database in a container and configure your application to use the database instead of the build-in database.

Launch a database and connect the application to it. 

Run this to start a MySQL container:

```execute
oc new-app --name db mysql:5.7 \
   -e MYSQL_USER=user \
   -e MYSQL_PASSWORD=password \
   -e MYSQL_DATABASE=vote 
```

MySQL will be started and configured as shown in the command arguments, e.g. with a database called ``vote`` and the ``user`` and `password` as stated. 

Take a look at the log output:

```execute
oc logs dc/db
```

Wait for the database to be running.  You will see `ready for connections` in the log output. 

At this point in time, the application does not know about the existence of the MySQL database. You need to re-configure the application to use the new database. 
To do that we need to change the vote application's environment variables and re-launch the pod.  The vote application looks for the existence of the environment variables and uses them to configure itself.  If database credentials are defined, the application connects to the database and provisions the needed tables and data. 

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

Check that the database is now populated:

<!--
POD=`oc get pods --selector app=workspace -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}'`; echo $POD

kubectl get pods --field-selector=status.phase=Running -o name
-->

```execute
mysql -h db.%project_namespace%.svc -u user -ppassword -D vote -e "show tables"
```

FIXME: Use this to fetch pod name

```
POD=`oc get pods --selector app=workspace -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}'`; echo $POD
```

```execute
mysql -h db.%project_namespace%.svc -u user -ppassword -D vote -e "show tables"'
```

After using the application and adding votes, check the votes in the database: 


```execute
mysql -h db.%project_namespace%.svc -u user -ppassword -D vote -e 'select * from poll;'
```


In this lab you have launched a database and connected the application to it.  
Now, the application is no longer  dependent on the built-in database and can freely scale out if needed. 

In the next lab ... FIXME


