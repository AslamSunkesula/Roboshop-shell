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

yum install nginx -y &>>$LOGFILE

VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGFILE

VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE

VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE

VALIDATE $? "Removing default index html files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOGFILE

VALIDATE $? "Downloading web artifact"

cd /usr/share/nginx/html &>>$LOGFILE

VALIDATE $? "Moving to default HTML directory"

unzip /tmp/web.zip &>>$LOGFILE

VALIDATE $? "unzipping web artifact"

cp /home/centos/roboshop-shell/roboshop.con /etc/nginx/default.d/roboshop.conf  &>>$LOGFILE

VALIDATE $? "copying roboshop config"

systemctl restart nginx  &>>$LOGFILE

VALIDATE $? "Restarting Nginx"
# Extract the frontend content

cd /usr/share/nginx/html

uunzip /tmp/web.zip >> $LOGFILE

# Create Nginx Reverse Proxy Configuration

cp  /home/centos/Roboshop-shell/roboshop.con /etc/nginx/default.d/roboshop.conf >> $LOGFILE

# Restart Nginx Service to load the changes of the configuration

systemctl restart nginx

VALIDATE "Restarting nginx service"