echo "Firstly let's Install everything that we need to run our app"
./scripts/install.sh

echo "Deleting cluster if exist and create one"
k3d cluster delete cluster mycluster
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
while true
  do kubectl port-forward -n argocd svc/argocd-server 8080:443 1>/dev/null 2>/dev/null
done &

while true
  do kubectl port-forward -n dev svc/wil42-playground 8888:8888 1>/dev/null 2>/dev/null 
done &