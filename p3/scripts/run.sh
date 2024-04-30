echo "Firstly let's Install everything that we need to run our app"
./scripts/install.sh

echo "Let s start clean\n let's delete cluster if exist and create mycluster"
# Uncomment this two lines before pushing
k3d cluster delete cluster mycluster
k3d cluster create mycluster
echo "Now let's create name space to manage the infra : 1 for the dev and one for argocd"
# Uncomment this two lines before pushing
kubectl delete namespace dev
kubectl delete namespace argocd
kubectl create namespace dev
kubectl create namespace argocd
# kubectl config set-context --current --namespace=argocd
echo "Let's deploy argocd"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "wait for argo cd" 
sleep 2
kubectl wait --timeout 600s --for=condition=Ready pods --all -n argocd
# kubectl config set-context --current --namespace=dev

echo "Open port to port forward"
kubectl port-forward -n argocd svc/argocd-server 8080:443 &

docker pull wil42/playground:v1
docker pull wil42/playground:v2
# TO run the container
docker run --name mycontainer -d wil42/playground:v2

#Apply confs 
echo " Apply conf file to kubectl"
kubectl apply -f confs/config.yml
kubectl wait --timeout 600s --for=condition=Ready pods --all -n argocd

# bash << EOF & &>/dev/null
# while true ; do
# 	sudo kubectl port-forward -n dev svc/wil-app 8888:8888 &>/dev/null
# 	sleep 5
# done
# EOF

echo 'Password: '
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo