#!/bin/bash

echo "Starting cleanup process"

# Stop and remove the Docker container
echo "Stopping and removing Docker container"
docker stop mycontainer
docker rm mycontainer

# Delete the K3s cluster
echo "Deleting K3s cluster"
k3d cluster delete mycluster

# Delete the namespaces
echo "Deleting namespaces"
kubectl delete namespace dev
kubectl delete namespace argocd

# Delete the Argo CD deployment
echo "Deleting Argo CD deployment"
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml



# Kill the port forwarding processes
echo "Killing port forwarding processes"
pkill -f "kubectl port-forward"

echo "Cleanup process completed"