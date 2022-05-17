#!/bin/bash
export AWS_PAGER=""
printf "\nPlease type region name you have used (e.g, eu-central-1, ap-southeast-1, etc.): "
read region
printf "\nPlease type your name and username (e.g, arif-funny-whale, ahmed-artistic-ram):"
read resourceName

printf "\nDeleting the key-pair"
#aws --region ${region} ec2 delete-key-pair --key-name ${resourceName}-keypair
aws --region ${region} ec2 delete-key-pair --key-name ${resourceName}-deployer-key 
if [[ $? -ne 0 ]] ; then printf "\nWasn't able to delete. Sorry.\n"; exit; fi

printf "\nCollecting Instance IDs"
instanceIds=$(aws --region  ${region} resourcegroupstaggingapi get-resources --resource-type-filters ec2 --tag-filters Key=resourceOwner,Values=${resourceName} Key=resourceType,Values=instance  | egrep 'i-[0-9A-Za-z]+' -o)

echo $instanceIds
printf "\nTerminating Instances"
for i in $(echo $instanceIds); do aws --region ${region} ec2 terminate-instances --instance-ids $i; done
if [[ $? -ne 0 ]] ; then printf "\nWasn't able to delete. Sorry.\n"; exit; fi

printf "\nCollecting security group"
securityGroup=$(aws --region  ${region} resourcegroupstaggingapi get-resources --resource-type-filters ec2 --tag-filters Key=Name,Values=${resourceName}| egrep "sg-[0-9a-zA-Z]+" -o)
echo $securityGroup

printf "\nDeleting security group"
aws --region ${region} ec2 delete-security-group --group-id ${securityGroup}
