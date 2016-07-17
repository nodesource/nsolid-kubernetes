## Setup

### Prerequisites

### VM

One of the following should be installed:

* [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
* [VMWare Fusion](https://www.vmware.com/products/fusion)

#### kubectrl

```bash
# linux/amd64
curl -Lo kubectl http://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
# linux/386
curl -Lo kubectl http://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/386/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
# linux/arm
curl -Lo kubectl http://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/arm/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
# linux/arm64
curl -Lo kubectl http://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/arm64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
#linux/ppc64le
curl -Lo kubectl http://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/ppc64le/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
# OS X/amd64 
curl -Lo kubectl http://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/darwin/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
# OS X/386 
curl -Lo kubectl http://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/darwin/386/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
```

#### minikube

```bash
# OS X
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.6.0/minikube-darwin-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

#Linux
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.6.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```

### Start minikube

```bash
minikube start
```

If docker is not installed or you want to minikube docker daemon.

```bash
eval $(minikube docker-env)
```

### Kubernetes Dashboard

```bash
minikube dashboard
```

### Stopping minikube

```bash
minikube stop
```