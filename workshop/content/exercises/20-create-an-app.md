In this exercise you will try out how to deploy a containerized application via the web console. OpenShift Container Platform offers different ways to deploy your applications. You can deploy a container image; or point Openshift Container Platform to a source code repository, to build and deploy the application. It also allows you to deploy an entire workload via Templates. In this exercise, we will see how easy it is to deploy a simple container image via the web console.

On the 'Console' tab, click on 'Home' -> Projects. You will see the a project that is created for you. You will deploy your applications in this project.

![project](images/deploy-img1.png)

Click on the project, you will be brought to the project console which shows that there is no workload running .

Now switch to the ``Developer`` perspective by clicking on the ``Administrator`` at the top of the left menu and selecting ``Developer``.  You will now see the Developer perspective which focuses on everything that a developer would be concerned about. 

You can now deploy a container my clicking on the ``+Add`` menu item. 

To deploy a container image, click on the '+Add' in the left menu.

![project](images/deploy-img2.png)


On the 'Deploy Image' page, enter:

```copy
openshiftroadshow/parksmap-katacoda:1.2.0
```

into the 'Image Name' text box and click on the magnifying class icon at the side. This will trigger a query from Docker hub to pull down the image information.

Click on 'Deploy' button to deploy the container image on OpenShift.
Behind the scene, Openshift will pull down the image, create the necessary Openshift objects (services, deploymentConfig) and deploy the image.

![project](images/deploy-img-a.png)

You will be lead to a page showing the status of the deployment.

![project](images/deploy-img-b.png)

Click on the deploymentConfig Object to open up a side menu for more information

![project](images/deploy-img-b1.png)


Next, click on ```Networking -> Routes``` on the left hand menu.
You will create a route to allow external access to the containerized application you have deployed.

Fill up the mandatory values on the ```Create Route``` page according to the screen-shot.
The values are: Name (e.g. mapapp), Service (select ``parksmap-katacoda``), Target Port (select ``8080``).

Click on Create.

![project](images/deploy-img-c.png)


You will be lead to the page displaying information on the Route object you have just created. Under the ```Location``` section on the right of the page, is the URL to access the application.

![project](images/deploy-img-d.png)

Click on the URL to access the application.  The application simply displays a map of the world.  If you see that, the application is running successfully!!

![project](images/deploy-img-e.png)


You have just got your first application running on OpenShift.  Congratulations!

Clean up the resources for this exercise, you won't be using them anymore.

```execute
oc delete all --all
```

In your terminal you should see all the configurations and objects being deleted. You will see similar output to the following:

```
pod "parksmap-katacoda-1-9f8xx" deleted
pod "parksmap-katacoda-1-deploy" deleted
replicationcontroller "parksmap-katacoda-1" deleted
service "parksmap-katacoda" deleted
deploymentconfig.apps.openshift.io "parksmap-katacoda" deleted
imagestream.image.openshift.io "parksmap-katacoda" deleted
route.route.openshift.io "myname" deleted
```

This concludes the section of the Lab.
