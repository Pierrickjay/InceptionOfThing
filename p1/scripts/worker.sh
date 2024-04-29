#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install net-tools -y
apt-get install curl -y
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.56.110:6443 --token-file /vagrant/token.env --node-ip=192.168.56.111" sh -
echo "alias k='kubectl'" >> /home/vagrant/.bashrc