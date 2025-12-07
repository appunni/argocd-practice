#!/bin/bash

echo "Checking prerequisites..."

check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is not installed."
        exit 1
    else
        # Try to get version, handle different version flags
        if [ "$1" == "k3d" ]; then
             version=$($1 --version | head -n 1)
        elif [ "$1" == "kubectl" ]; then
             version=$($1 version --client --short 2>/dev/null || echo "installed")
        elif [ "$1" == "argocd" ]; then
             version=$($1 version --client --short 2>/dev/null || echo "installed")
        else
             version="installed"
        fi
        echo "✅ $1 is $version"
    fi
}

check_tool docker
check_tool k3d
check_tool kubectl
check_tool argocd

echo "All tools are ready!"