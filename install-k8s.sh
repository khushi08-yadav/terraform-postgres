#!/bin/bash

apt update -y

# Install Docker and containerd
apt install -y docker.io containerd

systemctl enable docker
systemctl start docker
systemctl enable containerd
systemctl start containerd

# Disable swap
swapoff -a

# Install Kubernetes tools
apt install -y apt-transport-https ca-certificates curl gpg

mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | \
gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" \
> /etc/apt/sources.list.d/kubernetes.list

apt update -y
apt install -y kubelet kubeadm kubectl

# Initialize Kubernetes cluster
kubeadm init --pod-network-cidr=192.168.0.0/16

# Configure kubectl
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config

echo "Kubernetes setup completed!"
