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

if [[ $USERID -ne 0 ]]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [[ $1 -ne 0 ]]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}


# Install Nginx

yum install nginx -y &>> $LOGFILE

VALIDATE $? "Installing nginx"

# Enable and Start nginx service

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "Enabling nginx service"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "Starting nginx service"

# Remove the default content that web server is serving

rm -rf /usr/share/nginx/html/* >> $LOGFILE

VALIDATE $? "Deleting default content"

# Download the frontend content

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip >> $LOGFILE

VALIDATE $? "Downloading required content"

# Extract the frontend content

cd /usr/share/nginx/html

unzip -o /tmp/frontend.zip >> $LOGFILE

VALIDATE $? "unzipping cart"

# Create Nginx Reverse Proxy Configuration

cp -v /home/centos/Roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf >> $LOGFILE

# Restart Nginx Service to load the changes of the configuration

VALIDATE $? "copying roboshop config"

systemctl restart nginx  &>>$LOGFILE

VALIDATE $? "Restarting Nginx"