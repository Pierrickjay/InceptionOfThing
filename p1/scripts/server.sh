#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install net-tools -y
apt-get install curl -y
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san pjaySW --node-ip 192.168.56.110 --bind-address=192.168.56.110 --advertise-address=192.168.56.110" sh -
echo "alias k='kubectl'" >> /home/vagrant/.bashrc
sudo cat /var/lib/rancher/k3s/server/token > /vagrant/token.env