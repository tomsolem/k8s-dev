#!/bin/bash

# Configure container to use git-server
# copy ssh keys to the vscode user
cp /mnt/shared/* /home/vscode/.ssh/
# create ssh config
touch ~/.ssh/config
chmod 600 ~/.ssh/config
echo "Host git-server" >> ~/.ssh/config
echo "  HostName git-server" >> ~/.ssh/config
echo "  User git" >> ~/.ssh/config
echo "  IdentityFile ~/.ssh/git-server_id" >> ~/.ssh/config
# echo "  StrickHostKeyChecking no" >> ~/.ssh/config

# remove server from known_hosts if it exists
ssh-keygen -f "/home/vscode/.ssh/known_hosts" -R "git-server"

mkdir -p /home/vscode/dev
cd /home/vscode/dev
git clone ssh://git-server//srv/git/org/flux-gitops

# Start Minikube, with docker driver and cilium CNI
minikube start --driver=docker --cni=cilium

# Wait for Minikube to be up and running
echo "Waiting for Minikube to be up and running..."
while ! minikube status | grep -q "host: Running"; do
  echo "Minikube is not yet running. Waiting..."
  sleep 5
done

echo "Minikube is running!"


# Only check for the pre-requisites
echo "Checking Flux pre-requisites..."
if flux check --pre; then
  echo "Flux pre-requisites check passed. Installing Flux..."
  flux install
else
  echo "Flux pre-requisites check failed. Exiting..."
  exit 1
fi

flux create secret git flux-system --url=ssh://git-server/srv/git/org/flux-gitops --private-key-file=/home/vscode/.ssh/git-server_id

# Flux bootstrap
flux bootstrap git --url=ssh://git@git-server/srv/git/org/flux-gitops --path=clusters/minikube --branch=main --ssh-hostname=git-server:22

flux bootstrap git --url=ssh://git-server/srv/git/org/flux-gitops --private-key-file=/home/vscode/.ssh/git-server_id --ssh-hostname=git-server:22 --path=clusters/minikube --branch=main

# TODO: 
# - create a new private ssh key
# - add key to git server authorized_keys
# - clone the flux-gitops repo into the workspace (not the same folder as current worksspace)
# - set public key to be used by flux

# Add official Helm repositories for Istio and Kiali
echo "Adding official Helm repositories for Istio and Kiali..."
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add kiali https://kiali.org/helm-charts
helm repo add cilium https://helm.cilium.io/
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm repo update

# Missing CRD for Cilium. Need to install them prior to deploying Cilium
# install cilium helm repo
kubectl apply -f /workspaces/infrastructure/localhost/cilium/Helm-repository.yaml
# install cilium helm chart
kubectl apply -f /workspaces/infrastructure/localhost/cilium/Helm-release-cilium.yaml

# scale cilium-operator to 1 (not sure why the replicas are not set to 1)
#kubectl scale deployment cilium-operator --replicas=1 -n kube-system

# Deploy all the namespace for the environment (not sure why ecom is not in base)
#kubectl apply -k /workspaces/infrastructure/localhost/namespace
# Deploy application as needed for the environment
#ENVIRONMENT=dev
# Add custom crd / helmRleease for the environment
#kubectl apply -k /workspaces/infrastructure/$ENVIRONMENT/crds
# istio
#kubectl apply -k /workspaces/infrastructure/base/istio
#kubectl apply -k /workspaces/infrastructure/$ENVIRONMENT/istio