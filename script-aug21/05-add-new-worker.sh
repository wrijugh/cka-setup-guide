rg='rg-cka2'
storageacc=wgckastorage
vmimage=ubuntults
shutdownutc=1230 #Auto Shutdown time in UTC

vnet='cka-vnet';subnet='cka-subnet';

size='Standard_DS1' # check the available vm sizes in your region
# az vm list-sizes -l eastus -o table

workerprivateippref='10.230.0.2'
workeravblset='worker-avblset'

adminuser='cka'
adminpwd='ThatSuperSecret!@3$'

# Use Loop for >1 nic and VMs
for i in 2 2; do

        echo "----------------- 11b. Creating Worker VM's NIC($i) -----------------"
        az network nic create -g $rg -n worker-${i}-nic --private-ip-address $workerprivateippref${i} \
                        --vnet $vnet --subnet $subnet --ip-forwarding

        echo "----------------- 11c. Creating Worker VM($i) -----------------"
        az vm create -g $rg -n worker-${i} --image $vmimage --availability-set  $workeravblset \
                --nics worker-${i}-nic --size $size --authentication-type password --admin-username $adminuser \
                --admin-password $adminpwd --use-unmanaged-disk --storage-sku Standard_LRS --os-disk-size-gb 200

        echo "----------------- Configuring Worker VM's Auto Shutdown($i) -----------------"
        az vm auto-shutdown -n worker-${i} -g $rg --time $shutdownutc #UTC Zone
done