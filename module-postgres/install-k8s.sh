#!/bin/bash

set -e

apt update -y

# Install Docker and containerd
apt install -y docker.io containerd

systemctl enable docker
systemctl start docker
systemctl enable containerd
systemctl start containerd

# Disable swap
swapoff -a

# Disable swap permanently
sed -i '/ swap / s/^/#/' /etc/fstab

# Load required Kubernetes kernel modules
modprobe overlay
modprobe br_netfilter

# Make modules load automatically after reboot
cat <<EOF > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Configure Kubernetes networking
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

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

# Configure kubectl for root
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
