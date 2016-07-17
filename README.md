## Overview

This repository is for deploying [N|Solid](https://nodesource.com/products/nsolid) with [Kubernetes](http://kubernetes.io/). It assumes that Kubernetes is already setup for your environment.


### Installing kubernetes

* [local with minikube](./docs/install/local.md) - for local development / testing.
* [kubernetes on GKE](./docs/install/GKE.md) - Google Container Enginer
* [kubernetes on aws](http://kubernetes.io/docs/getting-started-guides/aws/) - Amazon Web Services
* [kubernetes on GCE](http://kubernetes.io/docs/getting-started-guides/gce/) - Google Compute Engine
* [kubernetes on Azure](http://kubernetes.io/docs/getting-started-guides/coreos/azure/) - Microsoft Azure (Weave-based)
* [kubernetes on Azure](http://kubernetes.io/docs/getting-started-guides/azure/) - Microsoft Azure (Flannel-based)

## Quickstart

Make sure your `kubectl` is pointing to your active cluster.

```bash
./install
```

### Access N|Solid Dashboard

* Default username: `nsolid`
* Default password: `demo`

**NOTE:** You will need to ignore the security warning on the self signed certificate to proceed.

#### With `minikube`

```bash
printf "\nhttps://$(minikube ip):$(kubectl get svc nsolid-secure-proxy --namespace=nsolid --output='jsonpath={.spec.ports[1].nodePort}')\n"
```

or

#### Cloud Deployment:

```bash
kubectl get svc nsolid-secure-proxy --namespace=nsolid
```

Open `EXTERNAL-IP`


### Uninstall N|Solid from kubernetes cluster

```bash
kubectl delete ns nsolid --cascade
```

## Manual Install

**NOTE:** Assumes kubectl is configured and pointed at your kubernetes cluster properly.

#### Create the namespace `nsolid` to help isolate and manage the N|Solid components.

```
kubectl create -f nsolid.namespace.yml
```

#### Create nginx SSL certificates

```
openssl req -x509 -nodes -newkey rsa:2048 -keyout conf/certs/nsolid-nginx.key -out conf/certs/nsolid-nginx.crt
```

#### Create Basic Auth file

```
rm ./conf/nginx/htpasswd
htpasswd -cb ./conf/nginx/htpasswd {username} {password}
```

#### Create a `secret` to for certs to mount in nginx

```
kubectl create secret generic nginx-tls --from-file=conf/certs --namespace=nsolid
```

#### Create `configmap` for nginx settings
```
kubectl create configmap nginx-config --from-file=nginx --namespace=nsolid
```

#### Define the services

```
kubectl create -f nsolid.services.yml
```

#### Deploy N|Solid components

```
kubectl create -f nsolid.quickstart.yml --record
```

### Access Dashboard

```
kubectl get svc nsolid-secure-proxy --namespace=nsolid
```

Open `EXTERNAL-IP`


## Deploying your App with N|Solid

### Quick Start

```bash
cd myapp
npm install
docker build -t myapp:v1 .
kubectl create -f myapp.service.yml
kubectl create -f myapp.deployment.yml
```

**NOTE:** container image in `myapp.deployment.yml` assumes `myapp:v1` docker file. This will work if your using `minikube` and ran `eval $(minikube docker-env)`.

### Scaling

Currently 3 instances of `myapp` are running. We can increase the number of replicas and the service will automatically load balance. N|Solid will automatically show an increase number of instances as well.

```bash
$ kubectl scale rc myapp --replicas=4
```
