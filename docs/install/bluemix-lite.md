## IBM Cloud Container Service

### Change service type before deploying N|Solid. 

If you are using the Lite (free) plan, you have a single VM Kubernetes cluster. This environment is limited to the NodePort service type. So before you deploy to a Lite Kubernetes cluster, make the following change to your conf/nsolid.services.yml file: 

```bash
From

    spec:
      type: LoadBalancer 

To

    spec:
      type: NodePort
```