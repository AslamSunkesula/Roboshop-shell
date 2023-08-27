#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

user=" "

if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE $? "Setting up NPM Source"

yum install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing the nodejs"

id useradd &>> $LOGFILE

if [ $? -ne 0 ]; then
    useradd roboshop &>>$LOGFILE

    VALIDATE "User roboshop created"
fi

DIR=/app

if [ ! -d "$DIR" ]; then

    mkdir /app &>>$LOGFILE

    VALIDATE "$DIR created"
fi

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE

VALIDATE $? "code dowmloading"

cd /app &>>$LOGFILE

unzip /tmp/catalogue.zip &>>$LOGFILE

VALIDATE $? "Unziping code"

npm install &>>$LOGFILE

VALIDATE $? "NPM dependecies installing"

cp /home/centos/Roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE

VALIDATE $? "Coping & creating the catalogue service"

systemctl daemon-reload &>>$LOGFILE

systemctl enable catalogue &>>$LOGFILE

VALIDATE $? "Enabling the catalogue"

systemctl start catalogue &>>$LOGFILE

VALIDATE $? "starting the catalogue service"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying mongo repo"

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing mongo client" &>>$LOGFILE

mongo --host  </app/schema/catalogue.js &>>$LOGFILE

VALIDATE $? "loading catalogue data into mongodb"
