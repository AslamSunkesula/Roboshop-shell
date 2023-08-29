#!/usr/bin/env bash

DATE=$(date +%F)
SCRIPT_NAME="$0"
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
W="\033[0m"

if [[ $(id -u) -ne 0 ]]
then
        echo -e "$R ERROR : Please run this sctipt with root user, swich to root and try $W"
        exit 1
fi

VALIDATE()
{
    if [[ $? -ne 0 ]]
        then
                echo -e "$1 $R ..... Failure $W"
                exit 2
        else
                echo -e "$1 $G ..... Success $W"
        fi
}

# Install Nginx

yum install nginx -y&>>  $LOGFILE

VALIDATE $? "Installing nginx"

# Enable and Start nginx service

systemctl enable nginx&>>  $LOGFILE

VALIDATE $? "Enabling nginx service"

systemctl start nginx&>>  $LOGFILE

VALIDATE $? "Starting nginx service"

# Remove the default content that web server is serving

rm -rf /usr/share/nginx/html/*&>>  $LOGFILE

VALIDATE $? "Deleting default content"

# Download the frontend content

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip&>>  $LOGFILE

VALIDATE $? "Downloading required content"

# Extract the frontend content

cd /usr/share/nginx/html

unzip /tmp/frontend.zip&>>  $LOGFILE

# Create Nginx Reverse Proxy Configuration

cp -v /home/centos/roboshop-shell/roboshop.con /etc/nginx/default.d/roboshop.conf&>>  $LOGFILE

# Restart Nginx Service to load the changes of the configuration

systemctl restart nginx &>>  $LOGFILE

VALIDATE $? "Restarting nginx service"