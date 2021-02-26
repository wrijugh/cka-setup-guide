# ===================================================================================================
# Wriju - Feb 26 2021
# https://github.com/pranabpaul/k8scerts/blob/main/configure
# https://medium.com/@patnaikshekhar/creating-a-kubernetes-cluster-in-azure-using-kubeadm-96e7c1ede4a
#
# ====================================================================================================
# ECONOMICAL VM - Using LRS Storage with Unmanaged Disks

# Set up Azure Resources
loc=eastus
rg='rg-cka'
storageacc=wgrandstorage
vmimage=ubuntults
shutdownutc=1230 #Auto Shutdown time in UTC

vnet=k8s-vnet
nsg=k8s-nsg
subnet=k8s-nsg

vnetaddressprefix='10.230.0.0/24'
subnetaddressprefix='10.230.0.0/27'

size='Standard_DS2'

cprivateip='10.230.0.10'
cpip=controller-pip
cnic=controller-nic

workerprivateippref='10.230.0.2'
# workerprivateip1=10.230.0.21
pipworker0=worker-0-pip
# pipworker1=worker-1-pip

workeravblset=worker-avblset

adminuser=wriju
adminpwd='P@ssw0rd!!!!' #must be min 12 char long

echo "----------------- Creating Resource Group -----------------"
# Create Resource Group in 
az group create -n $rg -l $loc

echo "----------------- Creating Storage Account -----------------"
# Create storage account and storage container
# No need to create any container or use the storage account name while creating vm 
# Because VM will find a storage account in the same resource group and create a container if not present vhds 
# if no storage account is available then vm create will create a storage account if --use-umamanged-disk option is provided.
az storage account create -n $storageacc -g $rg --sku Standard_LRS
#az storage container create -n vmhdd --account-name $storageacc

echo "----------------- Creating Virtual Network -----------------"
# Create virtual network
az network vnet create -g $rg -n $vnet --address-prefix $vnetaddressprefix

echo "----------------- Creating NSG -----------------"
# Create NSG
az network nsg create -g $rg -n $nsg

# Create a firewall rule to allow external SSH and HTTPS
az network nsg rule create -g $rg -n k8s-allow-ssh --access allow --destination-address-prefixes '*' --destination-port-range 22 --direction inbound --nsg-name $nsg --protocol tcp --source-address-prefixes '*' --source-port-range '*' --priority 1000

az network nsg rule create -g $rg -n k8s-allow-api-server --access allow --destination-address-prefixes '*' --destination-port-range 6443 --direction inbound --nsg-name $nsg --protocol tcp --source-address-prefixes '*' --source-port-range '*' --priority 1001

echo "----------------- Creating Subnet -----------------"
# Create Subnet
az network vnet subnet create -g $rg --vnet-name $vnet -n $subnet --address-prefixes $subnetaddressprefix --network-security-group $nsg

echo "----------------- Creating Controller VM's Public IP -----------------"
# Create nic and pip for controller VM
az network public-ip create -n $cpip -g $rg
echo "----------------- Creating Controller VM's NIC -----------------"
az network nic create -g $rg -n $cnic --private-ip-address $cprivateip --public-ip-address $cpip --vnet $vnet --subnet $subnet --ip-forwarding

echo "----------------- Creating Controller VM and Provisioning AutoShutdown -----------------"
# Provision controller VM
az vm create -g $rg -n controller --image $vmimage --nics $cnic --size $size --authentication-type password --admin-username $adminuser --admin-password $adminpwd --use-unmanaged-disk --storage-sku Standard_LRS --os-disk-size-gb 200
# az vm create -g rg-cka -n controller --image UbuntuLTS --size Standard_DS2 --use-unmanaged-disk --authentication-type=password --admin-username wriju --admin-password 'P@ssw0rd!!!!'
az vm auto-shutdown -g $rg -n controller --time $shutdownutc

# WORKER
echo "----------------- Creating Worker VM's Public IP, NIC, VM and Provisioning AutoShutdown -----------------"
# Create availability set, nics and pips for worker VMs
az vm availability-set create -g $rg -n $workeravblset --unmanaged

# Provision worker VMs
# Use Loop for >1 nic and VMs
for i in 0 1; do 
	echo "----------------- Creating Worker VM's Public IP -----------------"
	az network public-ip create -n worker-${i}-publicip -g $rg 

	echo "----------------- Creating Worker VM's NIC -----------------"
	az network nic create -g $rg -n worker-${i}-nic --private-ip-address $workerprivateippref${i} \
			--public-ip-address worker-${i}-publicip --vnet $vnet --subnet $subnet --ip-forwarding

	echo "----------------- Creating Worker VM -----------------"
	az vm create -g $rg -n worker-${i} --image $vmimage --availability-set  $workeravblset \
		--nics worker-${i}-nic --size $size --authentication-type password --admin-username $adminuser \
		--admin-password $adminpwd --use-unmanaged-disk --storage-sku Standard_LRS --os-disk-size-gb 200 
	
	echo "----------------- Configuring Worker VM's Auto Shutdown -----------------"
 	az vm auto-shutdown -n worker-${i} -g $rg --time $shutdownutc #UTC Zone
done

echo "----------------- DONE -----------------"