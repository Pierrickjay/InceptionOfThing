echo "Firstly let's Install everything that we need to run our app"
./scripts/install.sh

echo "Deleting cluster if exist and create one"
k3d cluster delete cluster mycluster
k3d cluster create mycluster

echo "Now let's create name space to manage the infra : 1 for the dev and one for argocd"
kubectl get namespace dev &>/dev/null && kubectl delete namespace dev
kubectl get namespace argocd &>/dev/null && kubectl delete namespace argocd
kubectl get namespace gitlab &>/dev/null && kubectl delete namespace gitlab
kubectl create namespace dev
kubectl create namespace argocd
kubectl create namespace gitlab


echo "Let's deploy argocd"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "wait for argo cd" 
sleep 2
kubectl wait --timeout 600s --for=condition=Ready pods --all -n argocd

echo "Let's setup gitlab"
    # Add the Helm repository
    helm repo add gitlab https://charts.gitlab.io/

    # Update the repo
    helm repo update

    # Install the GitLab chart : https://docs.gitlab.com/charts/installation/deployment.html#deploy-using-helm
    # https://docs.gitlab.com/charts/installation/deployment.html#deploy-the-community-edition
    helm install gitlab gitlab/gitlab --namespace gitlab \
-f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
--set global.hosts.domain=gitlab.com \
--set global.hosts.externalIP=0.0.0.0 \
--set global.hosts.https=false \
--set global.edition=ce \
--timeout 600s

echo "Let's deploy gitlab"
kubectl wait --namespace gitlab --for=condition=ready pod -l app=webservice --timeout=600s
echo "Gitlab is ready"

docker pull wil42/playground:v1
docker pull wil42/playground:v2

#Apply confs 
echo " Apply conf file to kubectl"
kubectl apply -f confs/config.yml
kubectl wait --timeout 600s --for=condition=Ready pods --all -n argocd

echo 'Password: '
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

GITLAB_PASSWORD=$(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d)

echo "Credentials -> Username: root - Password: $GITLAB_PASSWORD\n"
echo "GUI available at address: http://gitlab.com/"

echo "Open port to port forward"
while true
  do kubectl port-forward -n argocd svc/argocd-server 8080:443 1>/dev/null 2>/dev/null
done &

while true
  do kubectl port-forward -n gitlab svc/webservice 8081:8181 1>/dev/null 2>/dev/null
done

while true
  do kubectl port-forward -n gitlab svc/gitlab-gitlab-shell 32022:32022 1>/dev/null 2>/dev/null
done

while true
  do kubectl port-forward -n dev svc/wil42-playground 8888:8888 1>/dev/null 2>/dev/null 
done &
