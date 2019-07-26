# This is a workshop for OpenShift 4

This workshop uses Homeroom. If you are interested in Homeroom, a good place to start learning about it is by running it's [workshop on how to create content for Homeroom](https://github.com/openshift-homeroom/lab-workshop-content).

The dashboard for the workshop environment should look like:

![](.bin/screenshot.png)

## How to launch the workshop on OpenShift

To launch the workshop, first checkout a copy of this Git repository to your own computer.

```
git checkout https://github.com/sjbylo/lab-ocp4.git
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

Note that you will need to be a cluster admin in the OpenShift cluster to deploy a workshop for multiple users.

Once the deployment has completed, because this workshop is not currently setup to be automatically built into an image and hosted on an image registry, you will need to manually build the workshop image.

To build the workshop image run:

```
.workshop/scripts/build-workshop.sh
```

If you make changes to the workshop content, you can run this build command again. In the case of deploying it just for yourself, the workshop deployment will be automatically re-deployed. If you have deployed it for multiple users, any users currently using the workshop environment, will need to select "Restart Workshop" from the menu of the workshop dashboard.

Once deployed, visit the URL route for the workshop. You will be prompted to login to the OpenShift cluster. Use your own username and password. In the case of deploying the workshop for yourself, you will need to have been a project admin for the project it is deployed in.

You can learn more about the scripts used to perform the deployment by looking at the [README](.workshop/scripts/README.md) and files contained in the [.workshop/scripts](.workshop/scripts) directory.

If you need to ever update the deployment scripts to the latest version run:

```
git submodule update --recursive --remote
```

This will update the commit reference for the Git submodule, so if you want to keep it for the future, you will need to commit the change back to the repository.
