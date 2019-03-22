#this script will create a vpc with the following:

#VPC
    #Name: example_vpc_name
    #CIDR Block: example_vpc_cidr
#Subnet
    #Name: example_subnet_name
    #CIDR Block: example_subnet_cidr
#Internet Gateway
    #Name: example_gateway_name
#Routing Table
    #Name: example_routing_name
    #Associated with the: example_subnet_name subnet
    #A default route
    #Destination CIDR: example_destination_cidr
    #Gateway: example_gateway_name
#Security Group
    #What access points: allow ssh, http, https access from XXX
    #Name: example_security_group_name
    #Protocol: tcp, Port: 22, CIDR: example_incoming_cidr
    #Protocol: tcp, Port: 80, CIDR: example_incoming_cidr
    #Protocol: tcp, Port: 443, CIDR: example_incoming_cidr
#Will save the following variables to a temp file named state_file
    #vpc_id
    #subnet_id
    #gateway_id
    #route_table_id
    #rt_association_id
    #security_group_id

###Declare Variables###
declare vpc_cidr="example_vpc_cidr"
declare vpc_name="example_vpc_name"
declare subnet_cidr="example_subnet_cidr"
declare subnet_name="example_subnet_name"
declare gateway_name="example_gateway_name"
declare route_table_name="example_routing_name"
declare default_cidr="example_destination_cidr"
declare security_group_name="example_security_group_name"
declare security_group_desc="Allow http, https, and ssh access"
declare incoming_cidr="example_incoming_cidr"

#create the vpc and store it's id, then name it
vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --query Vpc.VpcId --output text)
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=$vpc_name

#create the subnet and store it's id, then name it
subnet_id=$(aws ec2 create-subnet  --vpc-id $vpc_id --cidr-block $subnet_cidr --query Subnet.SubnetId  --output text)
aws ec2 create-tags --resources $subnet_id --tags Key=Name,Value=$subnet_name

#create the gateway and store it's id, then name it
gateway_id=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
aws ec2 create-tags --resources $gateway_id --tags Key=Name,Value=$gateway_name

#attach gateway to vpc
aws ec2 attach-internet-gateway --internet-gateway-id $gateway_id --vpc-id $vpc_id

#create route table and store it's id, then name it
route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --query RouteTable.RouteTableId --output text)
aws ec2 create-tags  --resources $route_table_id  --tags Key=Name,Value=$route_table_name

#associate routing table to subnet and store the id
rt_association_id=$(aws ec2 associate-route-table --route-table-id $route_table_id --subnet-id $subnet_id --query AssociationId --output text)

#add default route to routing table
aws ec2 create-route --route-table-id $route_table_id --destination-cidr-block $default_cidr --gateway-id $gateway_id --output text 

#create security group, and create the 3 rules for 22, 80, 443
security_group_id=$(aws ec2 create-security-group --group-name $security_goup_name --description $security_group_desc --vpc-id $vpc_id --query GroupId --output text)
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr $incoming_cidr
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 80 --cidr $incoming_cidr
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 443 --cidr $incoming_cidr


#record a values to temp file
echo "vpc_id=$vpc_id" >> state_file
echo "subnet_id=$subnet_id" >> state_file
echo "gateway_id=$gateway_id" >> state_file
echo "route_table_id=$route_table_id" >> state_file
echo "rt_association_id=$rt_association_id" >> state_file
echo "security_group_id=$security_group_id" >> state_file