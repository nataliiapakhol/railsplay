#!/bin/bash

set -e
#Description:script to re_run instances for the railsplay app continious deployment
#Function that create new inctance

create_instance(){
	instance_id=$(aws ec2 run-instances --image-id ami-0e55e373 --security-group-ids sg-c93d36a0 --count 1 --instance-type t2.micro --key-name devenv-key --user-data file://provision/enviroment_provision.sh --tag-specifications 'ResourceType=instance,Tags=[{Key=name,Value=railsplay}]' --query 'Instances[0].InstanceId' | sed "s/\"//g")
	aws ssm put-parameter --name /railsplay/instance_id --value $instance_id --type String --overwrite 
	aws ec2 associate-address --instance-id $instance_id --allocation-id eipalloc-c3e6c6ed
}
old_instance_id=$(aws ssm get-parameter --name /railsplay/instance_id --query 'Parameter.Value' | sed "s/\"//g")

#Check if the instance_id parameter is set and take actions to terminate old instance if needed and run new instance.

if [ "" != "old_instance_id" ]; then
	aws ec2 terminate-instances --instance-ids $old_instance_id
	create_instance
else
	create_instance
fi
