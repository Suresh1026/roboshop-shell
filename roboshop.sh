#!/bin/bash

AMI=ami-0f3c7d07486cad139
SG_ID=sg-03bceb879f1cc352a
INSTANCES=("mongodb" "rabbitmq" "mysql" "Shipping" "user" "cart" "redis" "payment" "catalogue" "dispatch" "web")

for i in "${INSTANCES[@]}"
do
    echo "instance is: $i"
    if  [ $i = "mongodb" ] || [ $i = "mysql" ] || [ $i = "shipping" ]
    then
        INSTANCES_TYPE="t3.small"
    else
        INSTANCES_TYPE="t2.micro"
    fi


    aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $INSTANCES_TYPE 
    --security-group-ids sg-03bceb879f1cc352a --tag-specifications 
    "ResourceType=instance,Tags=[{Key=name,Value=$i}]"
    
done

