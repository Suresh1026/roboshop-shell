#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.sureshdayyala.online

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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading catalogue application" 

cd /app

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzipping catalogue" 

npm install &>> $LOGFILE

VALIDATE $? "npm installing" 

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Coping catalogue service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon reloaded" 

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabled catalogue" 

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting catalogue" 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo 

VALIDATE $? "copying mongodb repo" 

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing MongoDB client" 

mongo --host $MONGDB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalogue data into MongoDB" 




