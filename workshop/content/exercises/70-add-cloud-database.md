In this lab you will work with the already provisioned AWS Relational Database Service (RDS) instance and configure your application to use it.  Amazon RDS makes it easy to set up, operate, and scale MySQL deployments in the cloud. 

Check the status of the RDS instance:

```execute
svcat get instances
```

Wait for the instance _status_ to be ``Ready`` before continuing. 

Bind the new database with the application by creating a secret containing the access credentials (host, username, password...):

```execute
svcat bind mysql --name mysql-binding --secret-name mysql-secret
```

Check the RDS bindings:

```execute
svcat get bindings
```

The binding creates a secret containing the database's access credentials (host, username, password ...)

View the secret:

```execute
oc describe secret mysql-secret 
```
 - Note that if you see the error ``not found`` the secret has not been created yet.  This most likely means the RDS instance has not finished provisioning and/or the binding has not been created yet. 

---

FIXME: Not sure where to place this part yet. 

If not already done in the previous lab, the application needs to be configured to use a ``mysql`` database.  Add this setting to the application.

To do this, add the environment variable ``DB_TYPE`` into the application using the following command:

```execute
oc rollout pause dc vote-app 
oc set env dc vote-app \
   DB_TYPE=mysql
oc rollout resume dc vote-app
```

Note, that the above ``oc set env`` command would normally cause a re-deployment of the application.  In this case ``oc rollout pause dc vote-app`` is used to stop this from happening, since we are not ready to restart it just yet. 

---

Let's check that the RDS instance is reachable. 

Use the help script to extract the values from the secret into shell environment variables. 

```execute
eval `extract-secret mysql-secret`
```
Now, access the database to check the content of the ``vote`` database:

```execute
mysql -h $ENDPOINT_ADDRESS -P $PORT -u $MASTER_USERNAME -p$MASTER_PASSWORD -D $DB_NAME -e 'show databases;'
```
 This should also include the ``vote`` database.  
 Now, check is the database is empty or not.  
 
  - Note, It should be empty if the application has not initialized it yet.

```execute
mysql -h $ENDPOINT_ADDRESS -P $PORT -u $MASTER_USERNAME -p$MASTER_PASSWORD -D $DB_NAME -e 'show tables;'
```

Once the application has been configured to connect to the database, there will be content. 

Now, connect the application to the database by injecting the database credentials into the application.

To do this, add the credentials into the application by importing them into the ``deployment`` from the secret:

```execute
oc set env --from=secret/mysql-secret dc/vote-app
```

The previous command fetches the values in the secret ``mysql-secret`` and adds them into the deployment, which in turn re-deploys the application. 

Check the environment variables have been properly set:

```execute
oc set env dc/vote-app --list
```

Once the application has been re-deployed, check the database has been initialized:

```execute
mysql -h $ENDPOINT_ADDRESS -P $PORT -u $MASTER_USERNAME -p$MASTER_PASSWORD -D $DB_NAME -e 'show tables;'
```

After using the application, check the votes in the database: 

```execute
mysql -h $ENDPOINT_ADDRESS -P $PORT -u $MASTER_USERNAME -p$MASTER_PASSWORD -D $DB_NAME -e 'select * from poll;'
```

The above command should show the values needed to connect to the database. 

Once the application is running again, ensure it is still working:

```execute 
curl -s http://vote-app-%project_namespace%.%cluster_subdomain%/ | grep "<title>"
```

Test the application in a browser:

[Open the Vote Application](http://vote-app-%project_namespace%.%cluster_subdomain%/)

 - ``Note that your neighbor should also be able to access your application and submit a vote.`` 

After using the application and adding votes, check the votes in the database: 

```execute
mysql -h $ENDPOINT_ADDRESS -P $PORT -u $MASTER_USERNAME -p$MASTER_PASSWORD -D $DB_NAME -e 'select * from poll;'
```

---
The application can be tested using curl.

Post a few random votes to the application using:

```execute 
for i in {1..20}
do
   echo Casting vote nr. $i
   curl -s -X POST http://vote-app-%project_namespace%.%cluster_subdomain%/vote.html -d "vote=`expr $(($RANDOM % 9)) + 1`" >/dev/null
done
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


---




Now, de-provision the production database. 

First, the binding needs to be removed.  This means removing the credentials and the secret.

```execute
svcat unbind --name mysql-binding
```

... and then the MySQL service can be de-provisioned:

```execute
svcat deprovision mysql 
```

The MySQL instance will be removed and takes about 2 to 3 minutes.  
