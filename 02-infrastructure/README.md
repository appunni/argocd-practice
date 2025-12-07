# Exercise 02: Infrastructure Setup

## Goal
Provision two Kubernetes clusters on a shared Docker network using declarative configuration files:
*   **`argo-hub`**: The primary cluster where Argo CD will be installed and run.
*   **`argo-managed`**: The secondary cluster where Argo CD will deploy applications (the "target" cluster).

## 1. Create Infrastructure Configs
The configuration files are located in this directory.

### `k3d-hub.yaml`
This cluster will host Argo CD.
*   **Port 8080:443**: Maps host port 8080 to the load balancer's HTTPS port, allowing secure access to the Argo CD UI at `https://localhost:8080`.

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
network: argocd-net
```

### `k3d-managed.yaml`
This cluster will be managed by Argo CD.

```yaml
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: argo-managed
servers: 1
agents: 0
network: argocd-net
```

## 2. Provision the Environment
Run the following commands to create the network and clusters.

> **Note:** Ensure you are in the `02-infrastructure` directory before running these commands.

```bash
# 1. Create the shared network
docker network create argocd-net

# 2. Create the Hub Cluster
k3d cluster create --config k3d-hub.yaml

# 3. Create the Managed Cluster
k3d cluster create --config k3d-managed.yaml
```

## 3. Verify Clusters
Ensure both clusters are running and accessible.

```bash
kubectl config get-contexts
# You should see 'k3d-argo-hub' and 'k3d-argo-managed'
```
