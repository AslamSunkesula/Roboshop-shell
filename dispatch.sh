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

VALIDATE (){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}




# Install GoLang

yum install golang -y &>> $LOGFILE

VALIDATE $? "Installing GoLang"

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
    VALIDATE "$DIR Creation"
fi

# Download the application code to created app directory

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip &>> $LOGFILE

VALIDATE $? "Code downloading"

cd /app

unzip -o /tmp/dispatch.zip &>> $LOGFILE

VALIDATE $? "Unzipping code"

# Lets download the dependencies & build the software

cd /app 
go mod init dispatch
go get
go build

VALIDATE $? "Dependencies downloading and Building"

# Setup SystemD dispatch Service

cp -v /home/centos/Roboshope-shell/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE

VALIDATE $? "Creating dispatch service"

# Load, Enable and Start service

systemctl daemon-reload &>> LOGFILE

VALIDATE $? "demon-reload"

systemctl enable dispatch &>> $LOGFILE

VALIDATE $? "Enabling dispatch service"

systemctl start dispatch &>> $LOGFILE

VALIDATE $? "Starting dispatch service"