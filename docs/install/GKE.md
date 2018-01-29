## Setup

* Make sure Docker is installed
* Create a [Google Cloud](https://cloud.google.com/) account. (You can sign up for a free trial!)
* Create a Project in Google Cloud Dashboard.

### Enable Billing

Make sure [billing is enabled](https://support.google.com/cloud/answer/6293499#enable-billing) for project.

### Installing gcloud command line utilities

```bash
  # install gcloud
  curl https://sdk.cloud.google.com | bash
  # Restart shell
  exec -l $SHELL
  gcloud components install kubectl
  gcloud --quiet components update
```

### Setup gcloud defaults

```bash
gcloud auth login
gcloud config set project <PROJECT_ID>
gcloud config set compute/zone <ZONE>
```

* Your `PROJECT_ID` can be found in your dashboard
* A Cluster is deployed to a single zone. You can find [more about zones here](https://cloud.google.com/compute/docs/zones?hl=en). Or you can select one from the list generated from `gcloud compute zones list`

## Create a Cluster

```bash
gcloud container clusters create nsolid-cluster \
 --username admin \
 --password password \
 --num-nodes 3 \
 --machine-type n1-standard-1 \
 --disk-size 80 \
 --enable-cloud-logging \
 --enable-cloud-monitoring \
 --scope "https://www.googleapis.com/auth/devstorage.read_write" \
 --wait
```

* Username & Password flags are for accessing your Kubernetes cluster
* Enable cloud logging & monitoring flags only work if you have enabled them in the dashboard. Logging requires creating a bucket to dump log files to.
* Scope: Allows your instances to have oauth access to particular parts of the cloud api. In this case `devstorage.read_write` allows access to buckets.
* `wait` blocks the command until cluster and instances are ready. This could take 3-5 minutes.

If you omit the `password` flag google will create one for you. After your cluster is setup you can find it by

```bash
gcloud container clusters describe nsolid-cluster | grep password
```

### Set cluster as default

```bash
  gcloud config set container/cluster nsolid-cluster
  # share credentials with kubectl
  gcloud container clusters get-credentials nsolid-cluster
```

### Accessing your Kubernetes dashboard

```bash
kubectl cluster-info
```
The master url will provide you with a list of resource like the ui, swagger, logs, metrics, health, and api.
