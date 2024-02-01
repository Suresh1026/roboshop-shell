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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling current mysql server"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "copied mysql repo"

systemctl enable mysql &>> $LOGFILE

VALIDATE $? "Enabling mysql server"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "starting mysql server"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "setting MySql root password"


