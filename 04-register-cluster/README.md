# Exercise 04: Register Managed Cluster (Declarative)

In this exercise, we will register the `k3d-argo-managed` cluster with the Argo CD instance running on `k3d-argo-hub`.

We will use the **Service Account Token** method, which is the standard best practice for connecting clusters in Kubernetes.

### Why not use `argocd cluster add`?

In a typical environment, you might use the imperative `argocd cluster add` command. However, in a local `k3d` setup, this command fails because of networking differences:
1.  Your host machine sees the cluster at `localhost` (or `0.0.0.0`).
2.  The Argo CD container (running inside Docker) needs to reach the cluster at its internal Docker hostname (`k3d-argo-managed-serverlb`).

The CLI command automatically picks up the `localhost` address from your kubeconfig, which causes Argo CD to try connecting to itself. While we could hack the kubeconfig to fix this, using a **declarative Kubernetes Secret** is cleaner, more robust, and follows GitOps best practices.

## 1. The Strategy

1.  Create a `ServiceAccount` (`argocd-manager`) on the **Managed** cluster with `cluster-admin` privileges.
2.  Generate a long-lived `Bearer Token` for this account.
3.  Create a Kubernetes `Secret` on the **Hub** cluster containing this token and the managed cluster's API URL.

## 2. Setup Managed Cluster

First, we need to create the Service Account and RBAC roles on the managed cluster.

```bash
# Switch to Managed context
kubectl config use-context k3d-argo-managed

# Apply the setup manifest
kubectl apply -f managed-cluster-setup.yaml
```

## 3. Export Credentials

Now, we only need to extract the generated token. Since we are running in a local `k3d` environment, we can skip certificate verification (`insecure: true`) and hardcode the internal Docker URL.

```bash
# Extract the Bearer Token from the Secret we created
export BEARER_TOKEN=$(kubectl -n kube-system get secret argocd-manager-token -o jsonpath='{.data.token}' | base64 -d)
```

## 4. Register with Hub

Finally, we generate the secret and apply it to the Hub cluster.

```bash
# Switch to Hub context
kubectl config use-context k3d-argo-hub

# Substitute variables and apply
sed "s|\${BEARER_TOKEN}|$BEARER_TOKEN|g" cluster-secret.yaml | kubectl apply -f -
```

## 5. Verification

Verify that the cluster is registered in Argo CD:

```bash
# Check the secret exists
kubectl -n argocd get secrets -l argocd.argoproj.io/secret-type=cluster

# (Optional) If you have the CLI installed and logged in:
# argocd cluster list
``` if not already there
kubectl config use-context k3d-argo-hub

# Check the secret exists
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=cluster

# Check via Argo CD CLI (if logged in)
argocd cluster list
```

You should see `k3d-argo-managed` in the list with status `Successful`.
