
# run this in master to ge the join token 
sudo kubeadm token create --print-join-command

# kubeadm token list 

# Sample 
# kubeadm token create --print-join-command
# kubeadm join 10.230.0.10:6443 --token bqfs2e.29l1ii0l4gpqxt98 \
#     --discovery-token-ca-cert-hash sha256:bf55a001265f6ae52f7f4f1c51486c240ee302ccdf20c751785f48723e36fbb8 
