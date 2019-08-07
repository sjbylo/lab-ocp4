In this lab you will get to know ``Red Hat OpenShift`` and familiarize yourself with the command line and also with the web console. 

Red Hat OpenShift is an open source container application platform based on the Kubernetes container orchestrator for enterprise application development and deployment. 

If you are not familiar with the OpenShift Container Platform, it’s worth taking a few minutes to understand the basics of the platform as well as the environment that you will be using for this workshop.

The goal of OpenShift is to provide a great experience for both Developers and System Administrators to develop, deploy, and run containerized applications. Developers should love using OpenShift because it enables them to take advantage of both containerized applications and orchestration without having to know the details. Developers are free to focus on their code instead of spending time writing Dockerfiles and running docker builds.

OpenShift is a full platform that incorporates several upstream projects while also providing additional features and functionality to make those upstream projects easier to consume. The core of the platform is containers and orchestration. For the container side of the house, the platform uses images based upon the ``Open Container Initiative`` (a.k.a. Docker) image format. For the orchestration side, we have put a lot of work into the ``upstream Kubernetes`` project. Beyond these two upstream projects, we have created a set of additional Kubernetes objects such as ``routes`` and ``deployment configs`` that we will learn how to use during this workshop.

The command line tool that we will be using as part of this training is called the oc tool. This tool is provided for Windows, OS X, and the Linux Operating Systems.

OpenShift also provides a feature rich Web Console that provides a friendly graphical interface for interacting with the platform.

Let's get started!! 

First, using the command line, view how you are authenticated with OpenShift:

```execute
oc whoami
```

Your username is displayed.  

View the version of both ``oc`` - the client - and also the server:

```execute
oc version
```

Note the version of the server. Look for the "Major" and "Minor" numbers, e.g. 4 and 1+.

View the server endpoint through which you are authenticated.  

```execute
oc whoami --show-server
```

The endpoint shown serves all of the OpenShift APIs through which all tools, especially the ``oc`` client and the Web Console, communicate. If you are familiar with ``kubectl``, this command is also available. OpenShift includes a vanilla version of the upstream Kubernetes project that has been integrated & tested with other components of OpenShift and extended to provide functionality for a full PaaS experience. 

View the projects (namespaces) you have access to:

```execute
oc projects
```

Note, this project has been created for you (``%project_namespace%``) for the duration of the workshop. You will work in this project whilst others will work in their own projects, thus allowing everybody to work without interfering with each other.  This is part of the ``Role Based Access Control`` (RBAC) system which was developed by Red Hat and contributed to the upstream Kubernetes project. 

Fetch the console URL:

```execute
oc whoami --show-console
```

Using the below links, take a look at the OpenShift Console and view the following:

Your projects can be viewed here.  You should only have one: 

* [Projects](%console_url%) 

The status of your project can be seen here:

* [Status](%console_url%/overview/ns/%project_namespace%)

Click on the ``Dashboard`` button to see your resource usage in your project. As you have just started the workshop you are using nothing, so it shows 0% utilization for CPU and Memory.  

OpenShift events can be viewed here:

* [Events](%console_url%/k8s/ns/%project_namespace%/events)

If something is not working properly, this is a good place to look! 

Various OpenShift objects can be viewed:

* [Pods](%console_url%/k8s/ns/%project_namespace%/pods) 
* [Build Configs](%console_url%/k8s/ns/%project_namespace%/buildconfigs)
* [Deployment Configs](%console_url%/k8s/ns/%project_namespace%/deploymentconfigs)
* [Routes](%console_url%/k8s/ns/%project_namespace%/routes) 

<!--
* [Workloads](%console_url%/k8s/cluster/projects/%project_namespace%/workloads)
-->

You can view various technologies, including Source to Image, Templates and Operators here:

* [Developer Catalog](%console_url%/catalog/ns/%project_namespace%)

<!--
Note, this is not availabe on RHPDS 
* [Operator management](%console_url%/operatormanagement/ns/%project_namespace%)
-->

Come back to the terminal tab or click here:

* [Terminal](%terminal_url%)

Note that you can open the OpenShift Console in a separate tab by using the menu on the top right corner.

---
That's the end of this lab.

In this lab you were introduced to the OpenShift console and command line.  In the next lab, you will load and run your first container based application. 



