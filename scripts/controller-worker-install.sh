#=================================================================
# Install Docker, kubeadm, kubelet, kubectl in Controller & Worker 
#=================================================================
# Run following commands to install docker, kubelet, kubeadm and kubectl:

# -----------DOCKER--------------------
echo "------------------------ Install curl, https etc  ----------------------------"
# (Install Docker CE)
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
sudo apt-get update && sudo apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg2

# Add Docker's official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -

# Add the Docker apt repository:
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
echo "------------------------ containerd, docker-ce, docker-cli ----------------------------"
# Install Docker CE
sudo apt-get update && sudo apt-get install -y \
  containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)

## Create /etc/docker
sudo mkdir /etc/docker

# Set up the Docker daemon
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo usermod -aG docker $USER
newgrp docker

# -------------------
echo "------------------------ Install kubelet, kubeadm, kubectl ----------------------------"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

#--------------------
# Add the iptables rule to sysctl.conf
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf

# Enable iptables immediately
sudo sysctl -p

echo "------------------------ Restarting Docker ----------------------------"
# Restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
# ****************************************************************
#-------------------Run the below only in Controll plane 
#https://github.com/pranabpaul/k8scerts/blob/main/configure
#cert=b41a209250e1c96bad535d10c5e6efd0e2acce060cf03a33bf93ada25e1f5e8a
#cert=$(kubeadm certs certificate-key)
# sudo systemctl enable docker.service
# sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs --certificate-key $(kubeadm certs certificate-key)

# #-----------------
# # Sample Output
# # ----------------
# # kubeadm join 10.230.0.10:6443 --token ku8zyq.260duqkosz4uw5bk \
# #     --discovery-token-ca-cert-hash sha256:5ff0d2965d38ff21f211e62c16d39ce6a5fd820a7713a37cd158fd954312fa61

# # To find later-------------
# # kubeadm token create --print-join-command

# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

# # Install Claico
# kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

#Run the "Sample Output" to workers nodes kubeadm join