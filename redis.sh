#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE (){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R Failed $N"
        exit 1
    else
        echo -e "$2 ...$G Success $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R error: plese run this script with root user $N"
    exit 1
else
    echo "you are root user"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

VALIDATE $? "Installing Remi release"

dnf module enable redis:remi-6.2 -y

VALIDATE $? "Enabling Redis"

dnf install redis -y

VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf

systemctl enable redis

VALIDATE $? "Enabled Redis"

systemctl start redis

VALIDATE $? "Started Redis"