In this exercise you will work with the AWS Relational Database Service (``RDS``) instance you provisioned earlier and configure your application to use it.  Amazon RDS makes it easy to set up, operate, and scale MySQL deployments in the cloud. 

Check the status of the RDS instance:

```execute
svcat get instances
```


 - Important! Wait for the instance _status_ to become ``Ready`` before continuing. 


# Bind to the database service 

Bind to the new database service (called ``mysql``) with the application by first fetching the access credentials of the database (host, username, password...): 

Fetch the access credentials via the `service catalogue` by using the "``bind``" command: 

```execute
svcat bind mysql --name mysql-binding --secret-name mysql-secret
```

 - The binding will be called ``mysql-binding`` and the resulting Kubernetes secret will be called ``mysql-secret``.

 - Kubernetes secret objects let you store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys. Putting this information in a secret is safer and more flexible than putting it verbatim in a container. 

Check the database bindings:

```execute
svcat get bindings
```

The binding creates a secret containing the database's access credentials (host, username, password ...) 

View the secret:

```execute
oc describe secret mysql-secret 
```

You should see the following output:

```
Data
====
DB_NAME:           4 bytes
ENDPOINT_ADDRESS:  61 bytes
MASTER_PASSWORD:   15 bytes
MASTER_USERNAME:   4 bytes
PORT:              5 bytes
```

 - Note that if you see the error ``not found`` the secret has not been created yet.  This most likely means the RDS instance has not finished provisioning and/or the binding has not been created yet. 


# Verify the database is running 

Let's check that the RDS instance is up and reachable. 

Use the help script to extract the values from the secret into terminal's shell environment so the connectivity to the database can be tested. 

```execute
eval `extract-secret mysql-secret`
```
 - Note that if this command shows no output then it has succeeded. 
 - If this command returns ``not found`` wait for the database and its binding to be ``ready`` and the secret to be created from the binding. 

Now, access the database to check the content of the ``vote`` database:

```execute
mysql -h $ENDPOINT_ADDRESS -P $PORT -u $MASTER_USERNAME -p"$MASTER_PASSWORD" -D $DB_NAME -e 'show databases;'
```
 The output should include the ``vote`` database.  If not, or if there is an error, wait for the database to become ready. 
 
 Now, check if the database is empty or not.  
 
  - Note, the database `should be empty` if the application has not initialized it yet.

```execute
mysql -h $ENDPOINT_ADDRESS -P $PORT -u $MASTER_USERNAME -p"$MASTER_PASSWORD" -D $DB_NAME -e 'show tables;'
```

Only after the application has been configured to connect to the database and has started up, there will be any content in the database. 

```
+----------------+
| Tables_in_vote |
+----------------+
| option         |
| poll           |
+----------------+
```


<!--
# Point the application to the database 

If not already done in the previous exercise, the application needs to be configured to use a ``mysql`` database instead of the `built-in` database.  Add this setting to the application.

To do this, add the environment variable ``DB_TYPE`` into the application using the following command:

```execute
oc rollout pause dc vote-app 
oc set env dc vote-app \
   DB_TYPE=mysql
oc rollout resume dc vote-app
```

Note, that the above ``oc set env`` command would normally cause a re-deployment of the application.  In this case ``oc rollout pause dc vote-app`` is used to stop this from happening, since we are not ready to restart it just yet. 

-->

## Configure the application to use the database

Now, connect the application to the database by injecting the database credentials into the application.

To do this, add the credentials into the application by importing them into the ``deployment`` from the secret:

```execute
oc set env dc/vote-app \
    --from=secret/mysql-secret \
    DB_TYPE=mysql  
```
<!--
oc set env --from=secret/mysql-secret dc/vote-app 
-->

The previous command fetches the values from the secret ``mysql-secret`` and adds them into the deployment config, which in turn re-deploys the application. 

Check the environment variables have been properly set:

```execute
oc set env dc/vote-app --list
```

The above command should show the values needed to connect to the database. 

Once the application has been re-deployed, check the database has been initialized by the application:

```execute
mysql -h $ENDPOINT_ADDRESS -P $PORT -u $MASTER_USERNAME -p"$MASTER_PASSWORD" -D $DB_NAME -e 'show tables;'
```

Again, the tables (``poll`` and ``option``) should have been created.


## Test the application 

Post a few random votes to the application using the help-script:

```execute 
test-vote-app http://vote-app-%project_namespace%.%cluster_subdomain%/vote.html
```

After using the application, check the votes in the database table: 

```execute
mysql -h $ENDPOINT_ADDRESS -P $PORT -u $MASTER_USERNAME -p"$MASTER_PASSWORD" -D $DB_NAME -e 'select * from `option`;'
```

Once the application is running again, ensure it is still working:

```execute 
curl -s http://vote-app-%project_namespace%.%cluster_subdomain%/ | grep "<title>"
```

Test the application in a browser:

[Open the Vote Application](http://vote-app-%project_namespace%.%cluster_subdomain%/)

 - ``Note that your neighbor should also be able to access your application and submit a vote.`` 

After using the application and adding votes, check the votes in the database: 

```execute
mysql -h $ENDPOINT_ADDRESS -P $PORT -u $MASTER_USERNAME -p"$MASTER_PASSWORD" -D $DB_NAME -e 'select * from `option`;'
```

---
The application can be tested using curl.

Post a few random votes to the application using this help-script:

```execute 
test-vote-app http://vote-app-%project_namespace%.%cluster_subdomain%/vote.html
```

<!--
```execute 
for i in {1..20}
do
   echo Casting vote nr. $i
   curl -s -X POST http://vote-app-%project_namespace%.%cluster_subdomain%/vote.html -d "vote=`expr $(($RANDOM % 9)) + 1`" >/dev/null
done
```
-->

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
That's the end of this exercise.  

In this exercise you provisioned a RDS database in a container and connected the application to it. 





