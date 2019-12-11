In this exercise you will create a SpringBoot application from source code (using Source to Image) and run it on OpenShift. 

First, if not already, switch to the ``Developer`` perspective (click on the ``Administrator`` menu item and select ``Developer``). 

As we can see from the topology, there is no running application at the moment and we are presented with the following options to create applications. 


In this lab, we are looking to create the SpringBoot ``Pet Clinic`` application by referencing the source code in GitHub.  

Select the ``From Git`` option to kick off the application creation process. 

![Creating an application using the FROM GIT option](images/image1.png)

As a reference to Git for the source code, we will use this Git Repo URL: 

```copy
https://github.com/spring-projects/spring-petclinic
```


Click on the "Java" icon: 

![Building an application from source code in Git 1](images/image2.png)

``Builder image version``: Selected Java (version 11).

``Application Name``: spring-petclinic-git-app (naming convention is up to application creator, it can be a new application or added to an existing application).


![Building an application from source code in Git 2](images/image3.png)



The application starts to build.  The lack of presence of any coloured ring around the application donut indicates that the building process is ongoing.

By clicking the icon circled by the blue circle, we can inspect the ongoing process of the source code build.


![Waiting for the application build to complete](images/image4.png)

![Inspecting build process for Pet Clinic Application](images/image5.png)

Similar to the above, through the ``Events`` sub tab we can inspect the respective ongoing events in the process of the application creation.

![Viewing the event stream](images/image6.png)

A blue ring around the created Application denotes a successfully created application ready for usage.

Conversely, a red ring around the created Application denotes a failed creation of the application.

The application is ready to be accessed via its respective hostname, the hostname URL can be directly accessed through the icon in the green box.


![Pet Clinic Application has been successfully built](images/image7.png)

The running application looks like this:  

![Pet Clinic 1](images/image8.png)

![Pet Clinic 2](images/image9.png)


Congratulations!! You are now running a Java SpringBoot application on OpenShift.

