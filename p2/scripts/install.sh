apt-get update -y && apt-get upgrade -y

apt-get install curl -y

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san aboulestH --node-ip 192.168.56.110 --advertise-address=192.168.56.110 --flannel-iface eth1" sh -
echo "alias k='kubectl'" >> /home/vagrant/.bashrc

kubectl apply -f /tmp/confs/
