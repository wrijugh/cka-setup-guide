# 
# ========================================================
# This one should be run only to Controller and the
# output of  
# kubeadm token create --print-join-command
# ========================================================
#

sudo systemctl enable docker.service
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs --certificate-key $(kubeadm certs certificate-key)

# To find later-------------
# kubeadm token create --print-join-command

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Claico
kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

# Run the below and copy the output and execute to new worked to attach
kubeadm token create --print-join-command