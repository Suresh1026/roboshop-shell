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

dnf install nginx -y

VALIDATE $? "Installing nginx"

systemctl enable nginx

VALIDATE $? "enable nginx"

systemctl start nginx

VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*

VALIDATE $? "remove default content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "downloaded web application"

cd /usr/share/nginx/html

VALIDATE $? "moving nginx html directory"

unzip -o /tmp/web.zip

VALIDATE $? "unzipping web"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf 

VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx 

VALIDATE $? "restarted nginx"