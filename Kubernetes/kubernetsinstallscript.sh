#!/bin/bash
# install_k8s.sh
# A script to install a single-node Kubernetes cluster on an Ubuntu-based system.
#
# This script performs the following steps:
# 1. Pre-installation setup (disabling swap, firewall).
# 2. Installs Containerd as the container runtime.
# 3. Installs kubeadm, kubelet, and kubectl.
# 4. Initializes the Kubernetes control plane.
# 5. Configures kubectl for the current user.
# 6. Installs Weave Net as the pod network.
# 7. Untaints the master node to allow pods to be scheduled.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting Kubernetes installation..."

# ====================================================================
#  Pre-installation Setup
# ====================================================================

echo "Disabling swap, firewall, and configuring kernel modules..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo ufw disable


cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, these persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# ====================================================================
#  Install Containerd
# ====================================================================

echo "Installing Containerd..."
sudo apt-get update
sudo apt-get install -y containerd

# Create the directory for containerd's configuration file
sudo mkdir -p /etc/containerd

# Generate the default containerd configuration
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Edit the file to change the cgroup driver to systemd
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Restart and enable containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# ====================================================================
#  Install kubeadm, kubelet, kubectl
# ====================================================================

echo "Installing kubeadm, kubelet, and kubectl..."

# Add the Kubernetes apt repository
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install the tools
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Prevent them from being updated automatically
sudo apt-mark hold kubelet kubeadm kubectl

# ====================================================================
#  Initialize the Kubernetes Control Plane
# ====================================================================

echo "Initializing the Kubernetes control plane..."

# Prompt user for the VM's private IP address
echo "Please enter the private IP address of this VM:"
read -p "VM Private IP: " VM_IP

sudo kubeadm init --pod-network-cidr=10.0.0.0/16 --apiserver-advertise-address=$VM_IP

# ====================================================================
#  Configure kubectl and deploy pod network
# ====================================================================

echo "Configuring kubectl for the current user..."

# The following commands must be run as a regular user to set up kubectl config
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Waiting for the cluster to be ready before deploying the pod network..."
sleep 30

echo "Installing Weave Net pod network..."
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# Wait for nodes to become ready
echo "Waiting for nodes to become ready..."
while [[ $(kubectl get nodes | grep kubevm | awk '{print $2}') != "Ready" ]]; do
  echo "Node is not ready yet. Waiting..."
  sleep 10
done

echo "Untainting the master node..."
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo "Kubernetes installation complete!"
echo "You can check the status with: kubectl get nodes"




# kubeadm
#    = Build the Cluster

# kubelet
#    = Run the Cluster

# kubectl
#    = Manage the Cluster


# Ubuntu VM
#     ↓
# Disable Swap
#     ↓
# Install Containerd
#     ↓
# Install kubeadm, kubelet, kubectl
#     ↓
# Initialize Control Plane
#     ↓
# Configure kubectl
#     ↓
# Install Weave CNI
#     ↓
# Allow Pods on Master
#     ↓
# Cluster Ready