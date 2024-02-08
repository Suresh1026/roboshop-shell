#!/bin/bash

AMI=ami-0f3c7d07486cad139
SG_ID=sg-03bceb879f1cc352a
INSTANCES=("mongodb" "rabbitmq" "mysql" "Shipping" "user" "cart" "redis" "payment" "catalogue" "dispatch" "web")
ZONE_ID=Z01157182BWHQA6G8PULV
DOMAIN_NAME=sureshdayyala.online

for i in "${INSTANCES[@]}"
do
    if  [ $i = "mongodb" ] || [ $i = "mysql" ] || [ $i = "shipping" ]
    then
        INSTANCES_TYPE="t3.small"
    else
        INSTANCES_TYPE="t2.micro"
    fi
    
    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $INSTANCES_TYPE --security-group-ids sg-03bceb879f1cc352a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"

    #create Route53 records, make sure you delete existing
        aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
    '
done

