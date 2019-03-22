#script will create a vbox network

vboxmanage () { VBoxManage.exe "$@"; }

###Pathing###
declare = script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

###Declaring variables###
declare network_name="sys_net_prov"
declare network_address="192.168.254.0"
declare cidr_bits="24"
#global ip is empty so rule will match any ip address
declare global_ip=""
###SSH Port###
declare rule_name1="ssh_rule"
declare protocol1="TCP"
declare global_port1="50022"
declare local_ip1="192.168.254.10"
declare local_port1="22"
##HTTP Port###
declare rule_name2="http_rule"
declare protocol2="TCP"
declare global_port2="50080"
declare local_ip2="192.168.254.10"
declare local_port2="80"
##Httpd Port###
declare rule_name3="https_rule"
declare protocol3="TCP"
declare global_port3="50443"
declare local_ip3="192.168.254.10"
declare local_port3="443"
##PXE Port###
declare rule_name4="pxe_rule"
declare protocol4="TCP"
declare global_port4="50222"
declare local_ip4="192.168.254.5"
declare local_port4="22"

#adding a NAT network
vboxmanage natnetwork add --netname "${network_name}" --network "$network_address/$cidr_bits" --dhcp off 
#Ports
vboxmanage natnetwork modify --netname $network_name --port-forward-4 "$rule_name1:$protocol1:[$global_ip]:$global_port1:[$local_ip1]:$local_port1"
vboxmanage natnetwork modify --netname $network_name --port-forward-4 "$rule_name2:$protocol2:[$global_ip]:$global_port2:[$local_ip2]:$local_port2"
vboxmanage natnetwork modify --netname $network_name --port-forward-4 "$rule_name3:$protocol3:[$global_ip]:$global_port3:[$local_ip3]:$local_port3"
vboxmanage natnetwork modify --netname $network_name --port-forward-4 "$rule_name4:$protocol4:[$global_ip]:$global_port4:[$local_ip4]:$local_port4"