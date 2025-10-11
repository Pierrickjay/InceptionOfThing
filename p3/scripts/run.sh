#!/bin/bash

echo "Firstly let's Install everything that we need to run our app"
bash scripts/install.sh

echo "Deleting cluster if exist and create one"
k3d cluster delete mycluster 2>/dev/null || true
k3d cluster create mycluster

echo "Now let's create name space to manage the infra : 1 for the dev and one for argocd"
kubectl get namespace dev &>/dev/null && kubectl delete namespace dev
kubectl get namespace argocd &>/dev/null && kubectl delete namespace argocd
kubectl create namespace dev
kubectl create namespace argocd


echo "Let's deploy argocd"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "wait for argo cd" 
sleep 2
kubectl wait --timeout 600s --for=condition=Ready pods --all -n argocd

docker pull wil42/playground:v1
docker pull wil42/playground:v2

#Apply confs 
echo " Apply conf file to kubectl"
kubectl apply -f confs/config.yml
kubectl wait --timeout 600s --for=condition=Ready pods --all -n argocd

echo 'Password: '
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

echo "Open port to port forward"
echo "Starting port forwarding in background..."

# Port forward ArgoCD on all interfaces to allow access from host
kubectl port-forward -n argocd --address 0.0.0.0 svc/argocd-server 8080:443 &
ARGO_PID=$!

# Port forward application on all interfaces
kubectl port-forward -n dev --address 0.0.0.0 svc/wil42-playground 8888:8888 &
APP_PID=$!

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="
echo "ArgoCD UI: https://localhost:8080"
echo "Username: admin"
echo "Password: (see above)"
echo ""
echo "Application: http://localhost:8888"
echo "=========================================="
echo ""
echo "Port forwarding is running (PIDs: $ARGO_PID, $APP_PID)"
echo "Press Ctrl+C to stop"

# Keep the script running
wait