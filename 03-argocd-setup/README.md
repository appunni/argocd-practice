# Exercise 03: Argo CD Setup

## Goal
Install Argo CD on the Hub cluster and configure Ingress for access.

## 1. Install Argo CD (Declarative)
We will use Kustomize to install Argo CD and automatically patch it to run in "insecure" mode (HTTP). This ensures it works seamlessly with our Ingress controller.

1.  **Create `kustomization.yaml`**:
    ```yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    namespace: argocd

    resources:
      - https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    patches:
      - target:
          group: apps
          version: v1
          kind: Deployment
          name: argocd-server
        patch: |-
          - op: replace
            path: /spec/template/spec/containers/0/args
            value: ["/usr/local/bin/argocd-server", "--insecure"]
    ```

2.  **Apply the Configuration**:

    > **Note:** Ensure you are in the `03-argocd-setup` directory.

    ```bash
    # Switch context
    kubectl config use-context k3d-argo-hub

    # Create namespace
    kubectl create namespace argocd

    # Apply using Kustomize (current directory)
    kubectl apply -k .

    # Wait for pods to be ready
    kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
    ```

## 2. Expose Argo CD (Ingress)
We need to expose the Argo CD server so we can access it from our host machine.

> **How it works (TLS Termination):**
> 1.  **External:** You access `https://localhost:8080`. Docker forwards this to Traefik on port 443.
> 2.  **Termination:** Traefik handles the SSL handshake (using a self-signed cert) and decrypts the traffic.
>     *   The annotation `traefik.ingress.kubernetes.io/router.tls: "true"` enables this behavior.
> 3.  **Internal:** Traefik forwards the *decrypted* traffic (HTTP) to the `argocd-server` service on port 80.
> 4.  **Target:** The Argo CD pod (running with `--insecure`) accepts the HTTP request.

### `ingress.yaml`
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

1.  **Apply the Ingress**:
    ```bash
    kubectl apply -f ingress.yaml
    ```

## 3. Access Argo CD
Retrieve the initial password and login via CLI.

```bash
# Get the initial admin password
argocd admin initial-password -n argocd

# Login (using the load balancer port 8080)
# Username: admin
# Password: <output from above>
argocd login localhost:8080 --insecure
```
