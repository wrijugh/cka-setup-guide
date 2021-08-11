
# everything is like worker node plus 
# run worker-setup.sh in control plane as well

# run kubeadm
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.230.0.10

#Pod network https://www.weave.works/docs/net/latest/kubernetes/kube-addon/
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# this output will have two instructions. 
# 1. Move Kubeconfig file
# 2. attching new node 
#--------- Sample --------------

# To start using your cluster, you need to run the following as a regular user:

#   mkdir -p $HOME/.kube
#   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#   sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Alternatively, if you are the root user, you can run:

#   export KUBECONFIG=/etc/kubernetes/admin.conf

# You should now deploy a pod network to the cluster.
# Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#   https://kubernetes.io/docs/concepts/cluster-administration/addons/

# Then you can join any number of worker nodes by running the following on each as root:

# kubeadm join 10.230.0.10:6443 --token qvxgqj.ektksg8uvc6bm4sk \
#         --discovery-token-ca-cert-hash sha256:0f4ab975c2f2128595cacf12efee409736aec684fd19f7b9a42279e7a88706ca