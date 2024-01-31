#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling old nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabling new nodejs:18" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs" 

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating app directory" 

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading cart application" 

cd /app

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "Unzipping cart" 

npm install &>> $LOGFILE

VALIDATE $? "npm installing" 

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "Coping cart service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "cart daemon reloaded" 

systemctl enable cart &>> $LOGFILE

VALIDATE $? "enabled cart" 

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting cart" 






