#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}


# Install Python 3.6

yum install python36 gcc python3-devel -y &>>$LOGFILE

VALIDATE $? "Installing Python"

# Add application User if not exist

id roboshop &>> /dev/null
if [[ $? -ne 0 ]]
then
    useradd roboshop
    VALIDATE "User roboshop created"
fi

# This is a usual practice that runs in the organization. Lets setup an app directory if not exist

DIR="/app"
if [[ ! -d "$DIR" ]] 
then
    mkdir "$DIR"
    VALIDATE  "$DIR Creation"
fi

# Download the application code to created app directory

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip &>>$LOGFILE

VALIDATE $? "Downloading code"

cd /app

unzip -o /tmp/payment.zip &>>$LOGFILE

# This python app required dependenies. Lets download

pip3.6 install -r requirements.txt &>>$LOGFILE

VALIDATE $? "Installing dependencies"

# Setup SystemD Shipping Service

cp -v /home/centos/Roboshope-shell/payment.service /etc/systemd/system/payment.service &>>$LOGFILE

VALIDATE $? "Creating payment service"

# Load, Enable and Start service

systemctl daemon-reload

systemctl enable payment &>>$LOGFILE

VALIDATE $? "Enabling payment service"

systemctl start payment &>>$LOGFILE

VALIDATE $? "Starting payment service"