![NSolid, Docker, and Kubernetes](docs/images/container-banner.jpg)

## Overview

This repository is for deploying [N|Solid](https://nodesource.com/products/nsolid) with [Kubernetes](http://kubernetes.io/). It assumes that Kubernetes is already setup for your environment.

![NSolid, Docker, and Kubernetes](docs/images/kubernetes-cluster.png)

### Table of Contents
- [Installing kubernetes](#a1)
- [Quickstart](#a2)
    - [Access N|Solid Dashboard](#a3)
    - [Uninstall N|Solid](#a4)
- [Deploy Sample App with N|Solid](#a5)
- [Production Install](#a6)
    - [N|Solid namespace](#a7)
    - [nginx SSL certificates](#a8)
    - [Basic Auth file](#a9)
    - [Secret object for certs](#a10)
    - [Configmap object for settings](#a11)
    - [Define Services](#a12)
    - [GCE persistent disks](#a13)
    - [AWS persistent disks](#a14)
- [Debugging / Troubleshooting](#a15)
    - [Configuring Apps for N|Solid with kubernetes](#a16)
        - [Buiding an N|Solid app](#a17)
            - [Docker](#a18)
            - [Kubernetes](#a19)
        - [Accessing your App](#a20)
    - [Accessing N|Solid kubernetes objects](#a21)
        - [Setting `nsolid` as the default namespace](#a22)
    - [Running `nsolid-cli`](#a23)
    - [minikube](#a24)
        - [Setting ENV for cluster](#a25)
        - [Service Discovery](#a26)
    - [Common Gotchas](#a27)
- [License & Copyright](#a28)

<a name="a1"/>
## Installing kubernetes

* [local with minikube](./docs/install/local.md) - for local development / testing.
* [kubernetes on GKE](./docs/install/GKE.md) - Google Container Enginer
* [kubernetes on aws](http://kubernetes.io/docs/getting-started-guides/aws/) - Amazon Web Services
* [kubernetes on GCE](http://kubernetes.io/docs/getting-started-guides/gce/) - Google Compute Engine
* [kubernetes on Azure](http://kubernetes.io/docs/getting-started-guides/coreos/azure/) - Microsoft Azure (Weave-based)
* [kubernetes on Azure](http://kubernetes.io/docs/getting-started-guides/azure/) - Microsoft Azure (Flannel-based)

<a name="a2"/>
## Quickstart

Make sure your `kubectl` is pointing to your active cluster.

```bash
./install
```

This command will install the N|Solid Console, Hub, and a secure HTTPS proxy to the `nsolid` namespace.

It can take a little while for Kubernetes to download the N|Solid Docker images.  You can verify
that they are active by running:

```
kubectl --namespace=nsolid get pods
```

When all four pods (console, hub, nginx-secure-proxy, and registry) have a status of 'Running', you may continue to access the N|Solid Dashboard.

<a name="a3"/>
### Access N|Solid Dashboard

#### Secure credentials

* Default username: `nsolid`
* Default password: `demo`

#### With `minikube`

```bash
printf "\nhttps://$(minikube ip):$(kubectl get svc nginx-secure-proxy --namespace=nsolid --output='jsonpath={.spec.ports[1].nodePort}')\n"
```

or

#### Cloud Deployment:

```bash
kubectl get svc nginx-secure-proxy --namespace=nsolid
```

Open `EXTERNAL-IP`

**NOTE:** You will need to ignore the security warning on the self signed certificate to proceed.

![Welcome Screen](./docs/images/welcome.png)

<a name="a4"/>
### Uninstall N|Solid from kubernetes cluster

```bash
kubectl delete ns nsolid --cascade
```

<a name="a5"/>
## Deploy Sample App with N|Solid

### Quick Start

```bash
cd sample-app
docker build -t sample-app:v1 .
kubectl create -f sample-app.service.yml
kubectl create -f sample-app.deployment.yml
```

**NOTE:** container image in `sample-app.deployment.yml` assumes `sample-app:v1` docker image. This will work if your using `minikube` and ran `eval $(minikube docker-env)`.

If you are working in a cloud environment, you will need to push the sample-app to a public Docker registry
like [Dockerhub](https://dockerhub.com) or [Quay.io](https://quay.io), and update the sample-app Deployment file.


<a name="a6"/>
## Production Install

**NOTE:** Assumes kubectl is configured and pointed at your kubernetes cluster properly.

<a name="a7"/>
#### Create the namespace `nsolid` to help isolate and manage the N|Solid components.

```
kubectl create -f conf/nsolid.namespace.yml
```

<a name="a8"/>
#### Create nginx SSL certificates

```
openssl req -x509 -nodes -newkey rsa:2048 -keyout conf/certs/nsolid-nginx.key -out conf/certs/nsolid-nginx.crt
```

<a name="a9"/>
#### Create Basic Auth file

```
rm ./conf/nginx/htpasswd
htpasswd -cb ./conf/nginx/htpasswd {username} {password}
```

<a name="a10"/>
#### Create a `secret`  for certs to mount in nginx

```
kubectl create secret generic nginx-tls --from-file=conf/certs --namespace=nsolid
```

<a name="a11"/>
#### Create `configmap` for nginx settings
```
kubectl create configmap nginx-config --from-file=conf/nginx --namespace=nsolid
```

<a name="a12"/>
#### Define the services

```bash
kubectl create -f conf/nsolid.services.yml
```

#### Create persistent disks

N|Solid components require persistent storage.  Kubernetes does not (yet!)
automatically handle provisioning of disks consistently across all cloud providers.
As such, you will need to manually create the persistent volumes.

<a name="a13"/>
##### On Google Cloud

Make sure the zone matches the zone you brought up your cluster in!

```
gcloud compute disks create --size 10GB nsolid-registry
gcloud compute disks create --size 10GB nsolid-console
```

<a name="a14"/>
##### On AWS

We need to create our disks and then update the volumeIds in conf/nsolid.persistent.aws.yml.

Make sure the zone matches the zone you brought up your cluster in!

```
aws ec2 create-volume --availability-zone eu-west-1a --size 10 --volume-type gp2
aws ec2 create-volume --availability-zone eu-west-1a --size 10 --volume-type gp2
```


#### Configure Kubernetes to utilize the newly created persistent volumes

##### GCE
```bash
kubectl create -f conf/nsolid.persistent.gce.yml
```

##### AWS
```bash
kubectl create -f conf/nsolid.persistent.aws.yml
```

#### Deploy N|Solid components

```bash
kubectl create -f conf/nsolid.cloud.yml
```

<a name="a15"/>
## Debugging / Troubleshooting

<a name="a16"/>
### Configuring Apps for N|Solid with kubernetes

<a name="a17"/>
#### Buiding an N|Solid app

<a name="a18"/>
##### Docker

Make sure your docker image is build on top of `nodesource/nsolid:boron-2.0.1`.

```dockerfile
FROM nodesource/nsolid:boron-2.0.1
```

<a name="a19"/>
##### Kubernetes

When defining your application make sure the following `ENV` are set.

```yaml
  env:
    - name: NSOLID_APPNAME
      value: sample-app
    - name: NSOLID_COMMAND
      value: "storage.nsolid:9001"
    - name: NSOLID_DATA
      value: "storage.nsolid:9002"
    - name: NSOLID_BULK
      value: "storage.nsolid:9003"
```

Optional flags:

```yaml
  env:
    - name: NSOLID_TAGS
      value: "nsolid-boron-v2.0.1,staging"
```

A comma seperate list of tags that can be used to filter processes in the N|Solid console.

<a name="a20"/>
#### Accessing your App

```bash
kubectl get svc {service-name}
```

The `EXTERNAL-IP` will access the application.


<a name="a21"/>
### Accessing N|Solid kubernetes objects

Make sure you use the `--namespace=nsolid` flag on all `kubectl` commands.

<a name="a22"/>
#### Setting `nsolid` as the default namespace

```bash
kubectl config current-context // outputs current context
kubectl config set-context {$context} --namespace=nsolid // make 'nsolid` the default namespace
kubectl config set-context {$context} --namespace=default // revert to default
```

<a name="a23"/>
### Running `nsolid-cli`

**Verify CLI**:

```bash
kubectl exec {pod-name} -- nsolid-cli --hub=hub:80 ping
```

See [N|Solid cli docs](https://docs.nodesource.com/nsolid/2.0/docs/using-the-cli) for more info.


<a name="a24"/>
### minikube

Minikube is a bit different then a normal kubernetes install. The DNS service isn't running so discovering is a bit more involved. IP addresses are not dynamically assigned, instead we must use the host ports the service is mapped to.

<a name="a25"/>
#### Setting ENV for cluster

If your doing a lot of work with docker and minikube it is recommended that you run the following:

```bash
eval $(minikube docker-env)
```

<a name="a26"/>
### Service discovery

Get the kubernetes cluster ip address:

```bash
minikube ip
```

To get the service port:

```bash
kubectl get svc {$service-name} --output='jsonpath={.spec.ports[0].nodePort}'
```

**Note:** If your service exposes multiple ports you may want to examine with `--output='json'` instead.


<a name="a27"/>
### Common Gotchas

If you get the following message when trying to run `docker build` or communicating with the kubernetes api.

```bash
Error response from daemon: client is newer than server (client API version: 1.24, server API version: 1.23)
```

Export the `DOCKER_API_VERSION` to match the server API version.

```bash
export DOCKER_API_VERSION=1.23
```

<a name="a28" />
## License & Copyright

**nsolid-kubernetes** is Copyright (c) 2016 NodeSource and licensed under the MIT license. All rights not explicitly granted in the MIT license are reserved. See the included [LICENSE.md](LICENSE.md) file for more details.
