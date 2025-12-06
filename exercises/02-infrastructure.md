# Exercise 02: Infrastructure as Code

## Goal
Provision two Kubernetes clusters on a shared Docker network using declarative configuration files:
*   **`argo-hub`**: The primary cluster where Argo CD will be installed and run.
*   **`argo-managed`**: The secondary cluster where Argo CD will deploy applications (the "target" cluster).

## 1. Create Infrastructure Configs
Create a folder named `infra` and add the following files.

### `infra/k3d-hub.yaml`
This cluster will host Argo CD.
*   **Port 8080:443**: Maps host port 8080 to the load balancer's HTTPS port, allowing secure access to the Argo CD UI at `https://localhost:8080`.
*   **Port 6443:6443**: Maps host port 6443 to the API server. This ensures your local `kubectl` can communicate with the cluster on a standard port.

```yaml
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: argo-hub
servers: 1
agents: 0
ports:
  - port: 8080:443
    nodeFilters:
      - loadbalancer
  - port: 6443:6443
    nodeFilters:
      - server:0
network: argocd-net
```

### `infra/k3d-managed.yaml`
This cluster will be managed by Argo CD.
*   **Port 6444:6443**: Maps host port 6444 to the API server. We use a different port here to avoid a conflict with the Hub cluster (which is using 6443).

```yaml
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: argo-managed
servers: 1
agents: 0
ports:
  - port: 6444:6443
    nodeFilters:
      - server:0
network: argocd-net
```

### `infra/k3d-hub-ingress.yaml`
This Ingress resource will expose the Argo CD server.
*   **TLS Termination**: We configure Traefik to handle TLS (HTTPS) at the edge.
*   **Backend**: It routes traffic to the `argocd-server` service on port 80 (HTTP). This requires us to configure Argo CD to run in insecure mode later.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    ingress.kubernetes.io/ssl-redirect: "true"
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80
```

## 2. Provision the Environment
Run the following commands to create the network and clusters.

```bash
# 1. Create the shared network
docker network create argocd-net

# 2. Create the Hub Cluster
k3d cluster create --config infra/k3d-hub.yaml

# 3. Create the Managed Cluster
k3d cluster create --config infra/k3d-managed.yaml
```

## 3. Verify Clusters
Ensure both clusters are running and accessible.

```bash
kubectl config get-contexts
# You should see 'k3d-argo-hub' and 'k3d-argo-managed'
```
