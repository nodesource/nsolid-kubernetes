## Overview

This repository is for deploying [N|Solid](https://nodesource.com/products/nsolid) with [Kubernetes](http://kubernetes.io/). It assumes that Kubernetes is already setup for your environment.


### Installing kubernetes



* [minikube](https://github.com/kubernetes/minikube) - for local development / testing.
* [kubernetes on aws](http://kubernetes.io/docs/getting-started-guides/aws/) - Amazon Web Services
* [kubernetes on GKE](https://cloud.google.com/container-engine/docs/quickstart) - Google Container Engine
* [kubernetes on GCE](http://kubernetes.io/docs/getting-started-guides/gce/) - Google Compute Engine
* [kubernetes on Azure](http://kubernetes.io/docs/getting-started-guides/coreos/azure/) - Microsoft Azure (Weave-based)
* [kubernetes on Azure](http://kubernetes.io/docs/getting-started-guides/azure/) - Microsoft Azure (Flannel-based)

## Quickstart

Create the namespace `nsolid` to help isolate and manage the N|Solid components.

```
kubectl create -f nsolid.namespace.yml
```

Define the services

```
kubectl create -f nsolid.services.yml
```

Deploy N|Solid components

```
kubectl create -f nsolid.quickstart.yml --record
```

**NOTE:** Assumes kubectl is configured and pointed at your kubernetes cluster properly.


## Deploying your App with N|Solid

### Dockerize Application

#### Example `Dockerfile`

```
FROM nodesource/nsolid:latest

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

ADD server.js /usr/src/app/server.js

ENTRYPOINT ["nsolid", "server.js"]
```

#### Build Docker Image

```bash
docker build -t namespace/myapp:v1 .
```

Push image to a registry.

```bash
docker push namespace/myapp:v1
```

### Create Kubernete config files

`myapp-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: myapp
  selector:
    app: myapp
```

This tells kubernetes to create an external ip address and route all traffic on port 80 to the `myapp` targetPort. It will route to all pods that match the selector `app: myapp`.


`myapp-controller.yaml`

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 1
  selector:
    app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: namespace/myapp:v1
          env:
            - name: NSOLID_APPNAME
              value: myapp
            - name: NSOLID_HUB
              value: "registry:4001"
            - name: NSOLID_SOCKET
              value: "8000"
            - name: PORT
              value: "4444"
          ports:
            - containerPort: 4444
              name: myapp
            - containerPort: 8000
              name: nsolid
```

### Deploy

```bash
$ kubectl create -f myapp-service.yaml
$ kubectl create -f myapp-controller.yaml
```

We can check `kubectl get svc` to find out the external ip address. This is an async operation an may take a minute to full resolve and assign.

`myapp` Should display with the N|Solid console.


### Scaling

Currently only one instance of `myapp` is running. We can increase the number of replicas and the service will automatically load balance. N|Solid will automatically show an increase number of instances as well.

```bash
$ kubectl scale rc myapp --replicas=4
```
