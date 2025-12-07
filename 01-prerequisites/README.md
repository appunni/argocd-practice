# Exercise 01: Prerequisites & Setup

## Goal
Prepare your local environment with the necessary tools and initialize the GitOps repository.

## 1. Install Required Tools
Ensure you have the following CLI tools installed on your machine:

*   **Docker**: Container runtime.
*   **k3d**: Lightweight Kubernetes wrapper for Docker.
*   **kubectl**: Kubernetes command-line tool.
*   **argocd**: Argo CD command-line interface.

### Installation Commands (macOS/Homebrew)
```bash
brew install k3d kubectl argocd
# Docker Desktop must be installed separately
```

## 2. Initialize Git Repository
You need a GitHub repository to act as the "Source of Truth" for your GitOps workflow.

1.  **Create a new repository** on GitHub (e.g., `argocd-practice`).
2.  **Clone it locally**:
    ```bash
    git clone https://github.com/YOUR_USERNAME/argocd-practice.git
    cd argocd-practice
    ```

## 3. Verify Installation
Check that all tools are working correctly:
```bash
docker version
k3d version
kubectl version --client
argocd version --client
```
