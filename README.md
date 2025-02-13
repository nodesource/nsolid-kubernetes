[![N|Solid, Docker, and Kubernetes](docs/images/container-banner.jpg)](https://nodesource.com/products/nsolid)

# N|Solid Kubernetes Guide

This repository is an open-source guide for building and deploying a Next.js 15 project using N|Solid Docker images. N|Solid is an enterprise fork of Node.js with integrated monitoring that connects to the N|Solid Console. Although you can run N|Solid independently, the full benefits are unlocked when it is connected to the console.

The guide covers:

- Building Docker images (Alpine and Debian)
- CI/CD pipelines using GitHub Actions
- A sample Next.js “Hello World” application
- Basic Kubernetes configuration for deployment
- Configuring environment variables and secrets

## Repository Structure

- **docker/**  
  Contains Dockerfiles for building the images:
  - `Dockerfile.alpine` – Builds the Alpine-based image.
  - `Dockerfile.debian` – Builds the Debian-based image.
- **k8s/**  
  Contains Kubernetes manifests used for deployment:
  - Deployment, Service, Ingress, Secrets, ConfigMaps, and Persistent Volumes examples.
- **sample-app/**  
  A sample Next.js application (Hello World) to demonstrate deployment.
- **.github/workflows/**  
  Contains CI/CD pipeline files:
  - `alpine-build-amd.yml` – Builds the Alpine image for AMD64.
  - `alpine-build-arm.yml` – Builds the Alpine image for ARM64.
  - `debian-build-amd.yml` – Builds the Debian image for AMD64.
  - `debian-build-arm.yml` – Builds the Debian image for ARM64.

## Building the Docker Images

### GitHub Actions Pipelines

Separate GitHub Actions workflows are provided to build images for different platforms:

- **For Alpine-based images:**  
  Use `alpine-build-amd.yml` for AMD64 and `alpine-build-arm.yml` for ARM64.

- **For Debian-based images:**  
  Use `debian-build-amd.yml` for AMD64 and `debian-build-arm.yml` for ARM64.

Each workflow uses the appropriate Dockerfile (located in the `docker/` folder) and builds the image for the specified architecture.

### Local Build

To build locally, navigate to the repository root and run:

For Debian:

```bash
docker build -t sample-app:debian -f docker/Dockerfile.debian .
```

For Alpine:

```bash
docker build -t sample-app:alpine -f docker/Dockerfile.alpine .
```

## Deploying on Kubernetes

The `k8s/` folder contains basic configuration files to deploy the application. These include:

- **Deployment YAML:** Defines the N|Solid deployment with environment variables and secrets.
- **Service YAML:** Exposes the deployment internally in the cluster.
- **Ingress YAML:** Provides external access to the service.
- **Secrets & ConfigMaps:** Manage sensitive values (like `nsolid_saas`) and application settings.

### Example Deployment

Below is a sample Kubernetes Deployment manifest that sets up N|Solid. It configures two environment variables: `NSOLID_APPNAME` for the application name, and `NSOLID_SAAS`, which is injected from a secret called `nsolid-saas-secret`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nsolid-deployment
  labels:
    app: nsolid
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nsolid
  template:
    metadata:
      labels:
        app: nsolid
    spec:
      securityContext:
        runAsNonRoot: true
      containers:
        - name: nsolid
          image: yourrepo/nsolid:latest
          ports:
            - containerPort: 3000
          env:
            - name: NSOLID_APPNAME
              value: "Sample App"
            - name: NSOLID_TAGS
              value: "production,nextjs,nsolid-hydrogen"
            - name: NSOLID_SAAS
              valueFrom:
                secretKeyRef:
                  name: nsolid-saas-secret
                  key: nsolid_saas
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 5
      terminationGracePeriodSeconds: 30
```

### Creating the Secret

Before deploying, create the secret that holds the `nsolid_saas` value. Replace `<base64-encoded-secret>` with your base64-encoded value.

```bash
kubectl create secret generic nsolid-saas-secret --from-literal=nsolid_saas=<your-secret-value>
```

## How to Deploy

1. Build your Docker image (either via GitHub Actions or locally).
2. Push the image to your container registry if deploying to a cloud cluster.
3. Apply the Kubernetes manifests from the `k8s/` folder:
   ```bash
   kubectl apply -f k8s/
   ```
4. Monitor the deployment and check the pods:
   ```bash
   kubectl get pods --namespace=default
   ```

## Monitoring with N|Solid Console SaaS

N|Solid provides integrated monitoring. You can create a free account on the N|Solid Console SaaS to monitor your processes:

[Sign up for a free N|Solid Console account](https://accounts.nodesource.com/sign-up)

## About N|Solid

N|Solid is an enterprise version of Node.js with integrated monitoring and enhanced security. It connects to the N|Solid Console to provide real-time insights, process management, and more. Although it can be used as a standalone runtime, its full potential is realized when connected to the console. For more details, visit [nodesource.com](https://nodesource.com).

## License

This repository is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for more details.
