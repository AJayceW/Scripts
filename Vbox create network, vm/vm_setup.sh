#Creates a virtual machine running centos-7
#expects CentOS-7-x86_64-Minimal-1810.iso to be in /isos folder which should be located in same path as this script
#expects VBoxGuestAdditions.iso to be in /isos folder

vboxmanage () { VBoxManage.exe "$@"; }

###Variables for below###
declare vm_name="virtual_machine"

vboxmanage createvm --name ${vm_name} --register

#vboxmanage showvminfo displays line with the path to the config file -> grep "Config file returns it
declare vm_info="$(VBoxManage.exe showvminfo "${vm_name}")"
declare vm_conf_line="$(echo "${vm_info}" | grep "Config file")"

###Declare Variables###
declare size_in_mb=10000

declare ctrlr_name1=ide
declare ctrlr_name2=sata 
declare ctrlr_type1=ide
declare ctrlr_type2=sata

declare script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
declare iso_file_path="${script_dir}/isos/CentOS-7-x86_64-Minimal-1810.iso"
declare guest_additions_path="${script_dir}/isos/VBoxGuestAdditions.iso"
declare network_name="sys_net_prov"
declare memory_mb=1280
declare vm_folder="."

#create virtual hdd
vboxmanage createhd --filename "${vm_folder}/test-vm/${vm_name}.vdi" \
                    --size ${size_in_mb} -variant Standard

#add storage controllers
vboxmanage storagectl ${vm_name} --name $ctrlr_name1 --add ${ctrlr_type1} --bootable on
vboxmanage storagectl ${vm_name} --name $ctrlr_name2 --add ${ctrlr_type2} --bootable on

#attach installation ISO
vboxmanage storageattach ${vm_name} \
            --storagectl ${ctrlr_name1} \
            --port 0 \
            --device 0 \
            --type dvddrive \
            --medium ${iso_file_path}

#attach VirtualBox Guest Additions ISO file
vboxmanage storageattach ${vm_name} \
            --storagectl ${ctrlr_name1} \
            --port 1 \
            --device 0 \
            --type dvddrive \
            --medium ${guest_additions_path}

#attach hdd and specify that its an SSD
vboxmanage storageattach ${vm_name} \
            --storagectl ${ctrlr_name2} \
            --port 0 \
            --device 0 \
            --type hdd \
            --medium "${vm_folder}/test-vm/${vm_name}.vdi" \
            --nonrotational on

#configure vm
vboxmanage modifyvm ${vm_name}\
            --ostype "RedHat_64"\
            --cpus 1\
            --hwvirtex on\
            --nestedpaging on\
            --largepages on\
            --firmware bios\
            --nic1 natnetwork\
            --nat-network1 "${network_name}"\
            --macaddress1 "020000000001"\
            --cableconnected1 on\
            --audio none\
            --boot1 disk\
            --boot2 net\
            --boot3 dvd\
            --boot4 none\
            --memory "${memory_mb}"

#start the vm
vboxmanage startvm ${vm_name} --type gui
