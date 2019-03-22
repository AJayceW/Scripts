source './state_file'

#this script will create an ec2 with the following
    #image id: example_image_id
    #instance type: example_instance_type
    #instance ip: example_ip
    #key name: your key.pem file
    #block device mappings: "DeviceName=/dev/sda1,Ebs={DeleteOnTermination=true}"
    #security group ids: security group id from state file
    #subnet id: subnet id from state file
    #user data: example_file_loc

###Declare Variables###
declare ami_id="example_image_id"
declare instance_type="example_instance_type"
declare pem_key_name="example_pem_key"
declare instance_ip="example_ip"
#declare user_data="example_file_loc"
#security_group_id is retrieved from state file
#subnet_id is retrieved from state file
#elastic_ip_allocation_id is retrieved from state file

#create ec2 instance and store id
#delete EBS disk when instance terminates and block-device-mapping
instance_id=$(aws ec2 run-instances \
         --image-id $ami_id \
         --count 1 \
         --instance-type $instance_type \
         --block-device-mappings "DeviceName=/dev/sda1,Ebs={DeleteOnTermination=true}" \
         --key-name $pem_key_name \
         --security-group-ids $security_group_id \
         --subnet-id $subnet_id \
         --private-ip-address $instance_ip \
        # --user-data $user_data \
         --query 'Instances[*].InstanceId' \
         --output text)

#loop to wait for EC2 instance to come up
while state=$(aws ec2 describe-instances \
                        --instance-ids $instance_id \
                        --query 'Reservations[*].Instances[*].State.Name' \
                        --output text );\
      [[ $state = "pending" ]]; do
     echo -n '.' # show we are working on something
     sleep 3s    # wait three seconds before checking again
done

echo -e "\n$instance_id: $state"

#associate Elastic IP with EC2 instance storing the address association id
addr_association_id=$(aws ec2 associate-address \
                           --instance-id $instance_id \
                           --allocation-id $elastic_ip_allocation_id \
                           --query AssociationId \
                           --output text)