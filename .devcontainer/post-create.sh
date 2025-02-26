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

# remove server from known_hosts if it exists, this might happen if the server was recreated
ssh-keygen -f "/home/vscode/.ssh/known_hosts" -R "git-server"

# Clone the Flux GitOps repository
echo "Cloning the Flux GitOps repository..."
mkdir -p /home/vscode/dev
cd /home/vscode/dev
git clone ssh://git-server//srv/git/org/flux-gitops

cp -r /workspaces/* /home/vscode/dev/flux-gitops

# Start Minikube, with docker driver and cilium CNI
minikube start --driver=docker --cni=cilium

# Wait for Minikube to be up and running
echo "Waiting for Minikube to be up and running..."
while ! minikube status | grep -q "host: Running"; do
  echo "Minikube is not yet running. Waiting..."
  sleep 5
done

echo "Minikube is running!"

# Install Flux
# Only check for the pre-requisites
echo "Checking Flux pre-requisites..."
if flux check --pre; then
  echo "Flux pre-requisites check passed. Installing Flux..."
  flux install
else
  echo "Flux pre-requisites check failed. Exiting..."
  exit 1
fi
## Add custom dns to coredns
# to resolve the git-server hostname
sudo apt-get update
sudo apt-get install dnsutils -y

# Get the IP address of the git-server
GIT_SERVER_IP=$(nslookup git-server | grep 'Address' | tail -n 1 | awk '{print $2}')
echo "Git server IP address: $GIT_SERVER_IP"

# Add the git-server IP to the coredns-custom.yaml file
echo "Adding the git-server IP to the coredns-custom.yaml file..."
sed -i "s/{{GIT_SERVER_IP}}/$GIT_SERVER_IP/g" /workspaces/infrastructure/minikube/kube-system/coredns-custom.yaml
# apply the file to kubernetes
kubectl apply -f /workspaces/infrastructure/minikube/kube-system/coredns-custom.yaml
# restart coreDNS pod to reload the configMap
kubectl -n kube-system rollout restart deployment coredns

## Bootstrap Flux
# Create a secret for the git repository
flux create secret git flux-system --url=ssh://git-server/srv/git/org/flux-gitops --private-key-file=/home/vscode/.ssh/git-server_id

# Flux bootstrap
flux bootstrap git --url=ssh://git@git-server/srv/git/org/flux-gitops --private-key-file=/home/vscode/.ssh/git-server_id --path=clusters/minikube --branch=main --ssh-hostname=git-server:22 --insecure-skip-tls-verify

# TODO: 
# - add istio and kiali to the cluster
# - find out if helm cli has the repo added when flux installs it in cluster

# Add official Helm repositories for Istio and Kiali
echo "Adding official Helm repositories for Istio and Kiali..."
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add kiali https://kiali.org/helm-charts
helm repo add cilium https://helm.cilium.io/
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm repo update
