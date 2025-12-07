# Exercise 05: GitOps Workflow

## Goal
Deploy a sample "Nginx Demo" application to the `k3d-argo-managed` cluster using a proper GitOps structure.

## 1. The Structure

To simulate a real-world GitOps scenario, we have separated the **Application Source Code** from the **Argo CD Configuration**.

### A. The Application Repo (`nginx-demo-app/`)
This represents the developer's repository containing the actual application manifests (Kustomize).

```text
nginx-demo-app/
├── base/                   # The "Vanilla" application
│   └── nginx-demo/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── kustomization.yaml
└── overlays/               # Environment-specific modifications
    ├── dev/
    │   └── kustomization.yaml # Adds "dev-" prefix, 1 replica
    └── production/
        └── kustomization.yaml # Adds "prod-" prefix, labels
```

### B. The GitOps Repo (`05-gitops-workflow/`)
This represents the DevOps/Platform repository containing the Argo CD manifests that "glue" everything together.

```text
05-gitops-workflow/
├── apps/
│   ├── nginx-demo-project.yaml # Defines permissions (Source/Destination)
│   ├── nginx-demo-dev.yaml     # The Dev Application
│   └── nginx-demo-prod.yaml    # The Prod Application
```

## 2. Review the Configuration

Take a look at `05-gitops-workflow/apps/nginx-demo-prod.yaml`. You will see:
*   **Source:** Points to the `nginx-demo-app/overlays/production` path in this repo.
*   **Destination:** Points to `k3d-argo-managed` (the cluster we registered in Exercise 04).
*   **SyncPolicy:** set to `automated` (Argo CD will automatically apply changes).

## 3. Deploy

Since the files are already created, you just need to commit them to Git so Argo CD can see them.

1.  **Commit and Push**:
    ```bash
    git add nginx-demo-app 05-gitops-workflow
    git commit -m "feat: separate app source from gitops config"
    git push
    ```

2.  **Apply the Application**:
    Tell Argo CD to create the Project and Application.
    ```bash
    kubectl config use-context k3d-argo-hub
    
    # 1. Apply the Project first (Updated to allow dev namespace)
    kubectl apply -f 05-gitops-workflow/apps/nginx-demo-project.yaml

    # 2. Apply the Applications
    kubectl apply -f 05-gitops-workflow/apps/nginx-demo-prod.yaml
    kubectl apply -f 05-gitops-workflow/apps/nginx-demo-dev.yaml
    ```

3.  **Verify**:
    Check the Argo CD UI (localhost:8080) or CLI.
    ```bash
    argocd app list
    ```

## 4. Test the GitOps Loop (Optional)

To see GitOps in action:
1.  Edit `nginx-demo-app/base/nginx-demo/deployment.yaml` and change `replicas: 1` to `replicas: 3`.
2.  Commit and push the change.
3.  Watch Argo CD detect the drift and automatically sync the change (scale up the pods).
