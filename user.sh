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

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}



# Setup NodeJS repos

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE "Setting up nodejs repo"

# Install NodeJS

yum install nodejs -y &>>$LOGFILE

VALIDATE "Installing nodejs"

# Add application User if not exist

id roboshop &>> /dev/null
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "User roboshop created"
fi

# This is a usual practice that runs in the organization. Lets setup an app directory if not exist

DIR="/app"
if [ ! -d "$DIR" ]
then
    mkdir "$DIR"
    VALIDATE $? "$DIR Creation"
fi

# Download the application code to created app directory

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE

VALIDATE $? "downloading user artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving into app directory"

unzip -o /tmp/user.zip &>>$LOGFILE

VALIDATE $? "unzipping user"

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies"

# give full path of user.service because we are inside /app

cp /home/centos/Roboshop-shell/user.service /etc/systemd/system/user.service &>>$LOGFILE

VALIDATE $? "copying user.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload"

systemctl enable user &>>$LOGFILE

VALIDATE $? "Enabling user"

systemctl start user &>>$LOGFILE

VALIDATE $? "Starting user"
# Creating mongo repo for client installation

cp /home/centos/Roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Repo creation"

# Installing mongodb-client


yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing mongo client"

# Load Schema

mongo --host mongodb.aslamroboshop.online </app/schema/user.js &>>$LOGFILE

VALIDATE $? "Schema loading"