# Argo CD on k3d Workshop

Welcome to the Argo CD practice workshop! This repository contains a step-by-step guide to setting up a complete GitOps environment using k3d and Argo CD.

## Workshop Structure

The workshop is divided into the following exercises:

### [01. Prerequisites](./01-prerequisites/README.md)
- Check and install necessary tools (Docker, k3d, kubectl, argocd-cli).

### [02. Infrastructure Setup](./02-infrastructure/README.md)
- Create a Hub Cluster (for Argo CD).
- Create a Managed Cluster (target for deployments).
- Configure networking between clusters.

### [03. Argo CD Setup](./03-argocd-setup/README.md)
- Install Argo CD using Kustomize.
- Configure Ingress with Traefik.
- Set up TLS termination and access the UI.

### [04. Register Managed Cluster](./04-register-cluster/README.md)
- Configure RBAC on the managed cluster.
- Register the managed cluster using a declarative Kubernetes Secret.
- Configure TLS and authentication.

### [05. GitOps Workflow](./05-gitops-workflow/README.md)
- Deploy the Nginx Demo application to the managed cluster.
- Practice the GitOps workflow.

### [06. Cleanup](./06-cleanup/README.md)
- Destroy clusters and clean up resources.

## Getting Started

Start by navigating to the first exercise:

```bash
cd 01-prerequisites
```

Follow the instructions in each folder's `README.md`.

## Cleanup

To destroy the clusters and network created during this workshop, follow the instructions in:

[06. Cleanup](./06-cleanup/README.md)
