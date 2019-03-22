#this script will create an elastic ip with the following

#Will save the following variables to a temp file named state_file
    #elastic_ip_allocation_id
    #elastic_ip

#create elastic ip and store it's allocation id
elastic_ip_allocation_id=$(aws ec2 allocate-address --domain vpc --query AllocationId --output text)

#find and record the elastic ip address
elastic_ip=$(aws ec2 describe-addresses \
                          --allocation-ids $elastic_ip_allocation_id \
                          --query Addresses[*].PublicIp \
                          --output text)

echo "elastic_ip=$elastic_ip" >> state_file
echo "elastic_ip_allocation_id=$elastic_ip_allocation_id" >> state_file