## Kubernetes on IBM Cloud 

### Setup 

#### Getting Started 

Register and create a Lite Kubernetes cluster using the 
[IBM Bluemix Container Service](https://www.ibm.com/cloud-computing/bluemix/containers).

#### Install IBM Cloud Tools 

Linux/OSX install: 
```bash
curl -sL https://ibm.biz/idt-installer | bash
```

Windows install (and general information):

See: [https://github.com/IBM-Bluemix/ibm-cloud-developer-tools](https://github.com/IBM-Bluemix/ibm-cloud-developer-tools)

#### Address Kubernetes Cluster 

1. login 
    ```bash
    bx login -a api.ng.bluemix.net
    ```
1. export KUBECONFIG
    ```bash
    bx cs cluster-config mycluster
    ```
