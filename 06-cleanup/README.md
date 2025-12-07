# Exercise 06: Cleanup

This exercise covers how to clean up your local environment after finishing the practice session.

## Cleanup Steps

Run the following commands to remove the clusters and network resources.

### 1. Delete the Clusters

```bash
k3d cluster delete argo-hub
k3d cluster delete argo-managed
```

### 2. Delete the Network

Remove the shared Docker network used for cluster communication:

```bash
docker network rm argocd-net
```

### 3. Clean up Kubeconfig (Optional)

k3d usually removes the context from your kubeconfig automatically. If stale contexts remain, you can remove them:

```bash
kubectl config delete-context k3d-argo-hub
kubectl config delete-context k3d-argo-managed
```
