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

dnf install maven -y &>> $LOGFILE

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading shipping"

cd /app &>> $LOGFILE

VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOGFILE

VALIDATE $? "installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "renaming to jar"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "copying shippin service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "reloading daemon"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "enabled shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "started shipping"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "installing client server"

mysql -h mysql.sureshdayyala.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "loading shipping data"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "Restarting shipping"