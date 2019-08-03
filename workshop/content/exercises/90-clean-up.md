In this lab you will clean up and remove the provisioned resources. 

## Remove the RDS Instance 

De-provision the production cloud based database. 

First, the binding needs to be removed.  This means removing the credentials and the secret.  This can best be done through the service catalogue: 

```execute
svcat unbind --name mysql-binding
```

... and then the MySQL service can be de-provisioned:

```execute
svcat deprovision mysql 
```

The MySQL instance will be removed which takes about 5 to 10 minutes.  

Check the progress here:

```execute
svcat get instances 
```

## Remove the application and the container database

Now, remove the container based database 

```execute 
oc delete all --selector=app=db 
```

Notice how is it easy to remove parts of an application using the `selector` option and the name of the label `app=db`. 

Now, remove the application  

```execute 
oc delete all --selector=app=vote-app  
```

Again, we use the `selector` to remove only a part of the application. 

Just to be sure, remove everything from the project 

```execute 
oc delete all --all
```

---
That's the end of this lab.

Please go to the next lab. 
