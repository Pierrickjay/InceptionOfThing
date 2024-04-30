#!/bin/bash


command_exists() {
    command -v "$1" >/dev/null 2>&1
}



if ! command_exists k3d; then
    sudo apt-get install curl -y
    echo "k3d is not installed. Installing..."
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" #install kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

fi

# Check if Docker is installed
if ! command_exists docker; then
    sudo apt-get install curl -y
    echo "Docker is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
     # Start service
    sudo systemctl enable --now docker

    sudo groupadd docker
    sudo usermod -aG docker $USER
fi

echo "Everything is installed"
