## IBM Bluemix Container Service

### Get external IP and service port 

Linux/OSX: 
```bash
printf "\nhttps://$(bx cs workers mycluster | awk '{ split($2,t,"""Public"""); printf """%s+""", t[1] }' | awk '{ split($1,ip,"""+"""); print ip[3] }'):$(kubectl get svc nginx-secure-proxy --namespace=nsolid --output='jsonpath={.spec.ports[1].nodePort}')\n"
```
Note: if using this command for an application,  replace "nginx-secure-proxy" in the command text with the {service-name} of the application.

Windows: 

1. get Public IP
    ```bash
    bx cs workers mycluster
    ```
    The preceding bx command displays the public IP like this example: 
    ```bash
    ID                                                 Public IP         Private IP      Machine Type   State    Status   Version
    kube-hou02-pa2ccba8cbbcd243b39dd79fc0a6ad24bb-w1   184.172.236.206   10.76.114.209   free           normal   Ready    1.5.6_921
    ```

1. get service port 
    ```bash
    kubectl get svc nginx-secure-proxy --namespace=nsolid 
    ``` 
    Note: if using this command for an application,  replace "nginx-secure-proxy" in the command text with the {service-name} of the application.

    The preceding kubectl command displays the service ports like this example: 
    ```bash
    NAME                 CLUSTER-IP   EXTERNAL-IP   PORT(S)                      AGE
    nginx-secure-proxy   10.10.10.7   <pending>     80:32144/TCP,443:30238/TCP   8m
    ```
    The first node port (32144) is for http. The second (30238) is for https.