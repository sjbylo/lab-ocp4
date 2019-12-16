# OpenShift 4 with AWS Broker Workshop

This workshop is for OpenShift version 4.1 and above. It provides an introduction to OpenShift and 
developing an application which connects to an instance of MySQL via the Relational Database Service (RDS) of AWS. 

The workshop exercises can be found [here](https://github.com/sjbylo/lab-ocp4/tree/master/workshop/content/exercises).

This workshop uses the [AWS Broker](https://github.com/awslabs/aws-servicebroker/) to provision an RDS instance in AWS.  
The Broker needs to be installed and 
working on the OpenShift cluster for two of the exercises to work.  The instructions to install the
AWS Broker are [here](https://github.com/awslabs/aws-servicebroker/blob/master/docs/getting-started-openshift.md).
Note that, even if the AWS Broker is not available the other exercises still provide considerable learning of OpenShift. 

<!--
Please note this issue when installing the AWS Broker on OpenShift 4.1 https://github.com/awslabs/aws-servicebroker/issues/139 
-->

# Setup of the workshop using RHPDS 

A Red Hat RHPDS OCP 4.x cluster can be provisioned and used for this workshop.  Select "OpenShift 4 Workshop" from the catalog in RHPDS. The AWS Service Broker (AWSSB) is then installed and configured onto the RHPDS cluster.  The AWSSB can be configured to manage services in a separate AWS account or the same account (target account).  There are a few prerequisites that need to be configured into the target account which are described in the AWSSB documentation. 

## Increase the RDS limits in the Target AWS Account

If needed, the following [Amazon RDS limits need to be increased](https://console.aws.amazon.com/servicequotas/home#!/services/rds/quotas) to match the number of RDS instances (i.e. one per attendee) needed for the workshop.  It takes AWS about 3-5 days to make the changes. These are the limits that need increasing, e.g. set all these limits to 60 if you anticipate 60 workshop participants: 

```
DB cluster parameter groups = 60 (shows up as Custom (0/120))
DB instances = 60 
DB subnet groups = 60 
Option groups = 60 
Parameter groups = 60 
```

This is how the RDS resources should look in the AWS Console if you want to run 60 instances: 

<img src="images/rds-resources-for-60-instances.png" alt="drawing" width="500"/>

<!--
![project](images/rds-resources-for-60-instances.png)
-->

## Setup of the Target AWS Account 

**Follow the [instructions](https://github.com/awslabs/aws-servicebroker/blob/master/docs/getting-started-openshift.md) to allow the target account to be managed by the AWS Service Broker (AWSSB).**  This entails setting up IAM and a DynamoDB table.

## Prepare the RHPDS OpenShift cluster  

Following are the steps that were used to configure AWSSB onto a OCP 4.1 cluster, provisioned via RHPDS. 

Ensure the "Broker Management" option appears in the OpenShift Menu.  If this is already visible then there is probably no need to execute the next two commands.

As cluster admin, run the following: 

```
oc patch servicecatalogapiservers cluster --patch '{"spec": {"managementState": "Managed"}}' --type=merge

oc patch servicecatalogcontrollermanagers cluster --patch '{"spec": {"managementState": "Managed"}}' --type=merge
```

The output of these commands should show "patched". 

Wait for at least 30 minutes for the Service Catalog to be configured and for the "Broker Management" option to appear in the OpenShift menu.  

<img src="images/ocp-broker-management-menu.png" alt="drawing" width="400"/>

<!--![menu](images/ocp-broker-management-menu.png ) -->

## Deploy AWS Service Broker on the RHPDS OpenShift cluster 

Follow the ["Getting Started Guide - OpenShift"](https://github.com/awslabs/aws-servicebroker/blob/master/docs/getting-started-openshift.md) to run the "deploy.sh" script which will deploy AWSSB.  

 - Please note that I have fixed the deploy.sh script to work with OCP 4.x.  The git pull request may not have been accepted in the AWS Broker project yet (as of Oct 2019).  If so, use the below script! 

The deploy.sh script: 

```
#!/bin/bash
# From: https://github.com/awslabs/aws-servicebroker/blob/master/packaging/openshift/deploy.sh

ACCESSKEYID=$(echo -n $1 | base64)
SECRETKEY=$(echo -n $2 | base64)

# On OpenShift 4.x the project name has changed to "openshift-service-catalog-apiserver"
oc projects -q | grep -q "^kube-service-catalog$" && proj=kube-service-catalog
oc projects -q | grep -q "^openshift-service-catalog-apiserver$" && proj=openshift-service-catalog-apiserver
[ ! "$proj" ] && echo "Error: Cannot find project" && exit 1

# Fetch the cert 
CA=`oc get secret -n $proj -o go-template='{{ range .items }}{{ if eq .type "kubernetes.io/service-account-token" }}{{ index .data "service-ca.crt" }}{{end}}{{"\n"}}{{end}}' | grep -v '^$' | tail -n 1`

# Create the project and the AWS Service Broker
oc new-project aws-sb 
oc process -f aws-servicebroker.yaml --param-file=parameters.env \
	--param BROKER_CA_CERT=$CA \
	--param ACCESSKEYID=${ACCESSKEYID} \
	--param SECRETKEY=${SECRETKEY} | oc apply -f - -n aws-sb
```

Running the script should look like this

```
$ ./deploy.sh AKIAIUHIUH2FCJBJBFKG 'UHuhde73873hhjhUHGIUH8798798xxxxxxxxxxxx' 
Now using project "aws-sb" on server "https://api.cluster-workshop-a011.workshop-a011.example.opentlc.com:6443".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app django-psql-example

to build a new example application in Python. Or use kubectl to deploy a simple Kubernetes application:

    kubectl create deployment hello-node --image=gcr.io/hello-minikube-zero-install/hello-node

serviceaccount/aws-servicebroker-client created
secret/aws-servicebroker created
clusterservicebroker.servicecatalog.k8s.io/aws-servicebroker created
serviceaccount/aws-servicebroker created
clusterrole.rbac.authorization.k8s.io/aws-servicebroker created
clusterrole.rbac.authorization.k8s.io/access-aws-servicebroker created
clusterrolebinding.rbac.authorization.k8s.io/aws-servicebroker created
clusterrolebinding.rbac.authorization.k8s.io/aws-servicebroker-client created
service/aws-servicebroker created
secret/aws-servicebroker-credentials created
deployment.extensions/aws-servicebroker created

```


After running the "deploy.sh" script you should observer the following in the logs of the "aws-servicebroker" pod:

```
oc logs aws-servicebroker-6dcd88cc7d-mrbzc -n aws-sb 
...
converting service definition "rdsmssql"
...
Starting server on :3199
```

# Verify AWS Service Broker is working

Install the svcat script (e.g. for [Mac](https://svc-cat.io/docs/install/#macos)).  Try the following commands:

```
$ svcat describe broker aws-servicebroker
  Name:     aws-servicebroker
  Scope:    cluster         
  URL:      https://aws-servicebroker.aws-sb.svc.cluster.local  
  Status:   Ready - Successfully fetched catalog entries from broker @ 2019-10-15 03:19:06 +0000 UTC  
```

```
$ svcat get classes | grep rds
  rdsoracle                      AWS Service Broker - Amazon    
  rdsmssql                       AWS Service Broker - Amazon    
  rdsmariadb                     AWS Service Broker - Amazon    
  rdspostgresql                  AWS Service Broker - Amazon    
  rdsmysql                       AWS Service Broker - Amazon   
```

```
svcat marketplace | grep rds
  rdsoracle          production     AWS Service Broker - Amazon   
  rdsmssql           dev            AWS Service Broker - Amazon   
  rdsmariadb         custom         AWS Service Broker - Amazon   
  route53            recordset      AWS Service Broker - Amazon   
  rdspostgresql      production     AWS Service Broker - Amazon   
  rdsmysql           custom         AWS Service Broker - Amazon
```


# Homeroom workshop setup

This workshop uses Homeroom. If you are interested in Homeroom, a good place to start learning about it is by running it's [workshop on how to create content for Homeroom](https://github.com/openshift-homeroom/lab-workshop-content).

The dashboard for the workshop environment should look like:

![](images/screenshot.png)

## How to launch the workshop on OpenShift

To launch the workshop, first clone a copy of this Git repository to your own computer.

```
git clone --recurse-submodules https://github.com/sjbylo/lab-ocp4.git
```

Then within the Git repository directory, run:

```
git submodule update --init --recursive
```

This will checkout a copy of a Git submodule which contains scripts to help you deploy the workshop.

You now have two choices to deploy the workshop. You can deploy it for just yourself, or you can deploy it for a workshop where you have multiple users.

To deploy it just for yourself, run:

```
.workshop/scripts/deploy-personal.sh
```

To deploy it for a workshop with multiple users, run:

```
.workshop/scripts/deploy-spawner.sh
```

The output of this command should contain the following:

```
$ .workshop/scripts/deploy-spawner.sh
### Parsing command line arguments.
...
clusterrole.authorization.openshift.io/lab-ocp4-spawner-extra created
...
imagestream.image.openshift.io/lab-ocp4-session created
### Waiting for the spawner to deploy.
...
replication controller "lab-ocp4-spawner-1" successfully rolled out
### Install spawner resource definitions.
### Update spawner configuration for workshop.
### Updating spawner to use image for workshop.
Tag lab-ocp4-session:latest set to quay.io/openshifthomeroom/workshop-dashboard:5.0.0.
### Restart the spawner with new configuration.
deploymentconfig.apps.openshift.io/lab-ocp4-spawner rolled out
### Waiting for the spawner to deploy again.
...
replication controller "lab-ocp4-spawner-2" successfully rolled out
### Route details for the spawner are as follows.
lab-ocp4-aws-sb.apps.cluster-workshop-a011.workshop-a011.example.opentlc.com
```


Note that you will need to be a cluster admin in the OpenShift cluster to deploy a workshop for multiple users.

Once the deployment has completed, because this workshop is not currently setup to be automatically built into an image and hosted on an image registry, you will need to manually build the workshop image.

To build the workshop image run:

```
.workshop/scripts/build-workshop.sh
```

If you make changes to the workshop content, you can run this build command again. In the case of deploying it just for yourself, the workshop deployment will be automatically re-deployed. If you have deployed it for multiple users, any users currently using the workshop environment, will need to select "Restart Workshop" from the menu of the workshop dashboard.

Once deployed, visit the URL route for the workshop. You will be prompted to login to the OpenShift cluster. Use your own username and password. In the case of deploying the workshop for yourself, you will need to have been a project admin for the project it is deployed in.

You can learn more about the scripts used to perform the deployment by looking at the README and files contained in the `.workshop/scripts` directory.

If you need to ever update the deployment scripts to the latest version run:

```
git submodule update --recursive --remote
```

This will update the commit reference for the Git submodule, so if you want to keep it for the future, you will need to commit the change back to the repository.

To delete a personal workshop instance when done, run:

```
.workshop/scripts/delete-personal.sh
```

To delete a multi user workshop instance when done, run:

```
.workshop/scripts/delete-spawner.sh
```

## Configure the workshop

You must ensure the workshop is configured correctly to allow enough time and resources for the duration of the workshop.  If you don't check this, some or all of the  participants may not be able to access the workshop!

Check the current workshop configuiration with:

```
oc set env dc/lab-ocp4-spawner --list
```

Check the workshop configuration file for the settings used: ``.workshop/settings.sh``

You can make changes to the running workshop by setting the current environment variables.  Note: This will restart the workshop and all sessions:

For example, here the values are set for an idle session timeout of `2 hours`, a maximum session age of `6 hours` (1 or 2 hours longer than the expected duration of the workshop), a server limit for `60` participants and a resource budget of `unlimited` (therefor no cpu/ram limits set):

```
oc set env dc/lab-ocp4-spawner \
	IDLE_TIMEOUT=7200 \
	MAX_SESSION_AGE=21600 \
	SERVER_LIMIT=60 \
	RESOURCE_BUDGET=unlimited 
```

Also, see more on how to [configure and manage the workshop environment](https://github.com/openshift-homeroom/workshop-scripts#configuring-deployments). 

## Tidy up

Delete the build configuration for the workshop image by running:

```
.workshop/scripts/delete-workshop.sh
```

