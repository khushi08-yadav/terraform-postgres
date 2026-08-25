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
kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf
# Install Flannel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Allow workloads on single control-plane node
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify Helm
helm version

echo "Kubernetes + Helm setup completed!"
