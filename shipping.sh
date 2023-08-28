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



# Setup NodeJS repos

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE "Setting up nodejs repo"

# Install NodeJS

yum install nodejs -y &>>$LOGFILE

VALIDATE "Installing nodejs"

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


# Maven is a Java Packaging software, Hence we are going to install maven, This indeed takes care of java installation

yum install maven -y &>>$LOGFILE

VALIDATE "Installing maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip &>>$LOGFILE

VALIDATE $? "Code downloading"

cd /app

unzip /tmp/shipping.zip &>>$LOGFILE

VALIDATE $? "Unzipping code"

# Downloading dependenices and building application

mvn clean package &>>$LOGFILE

mv target/shipping-1.0.jar shipping.jar

# Setup SystemD Shipping Service

cp -v /home/centos/Roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE

VALIDATE $? "Creating shipping service"

# Load, Enable and Start service

systemctl daemon-reload

systemctl enable shipping &>>$LOGFILE

VALIDATE $? "Enabling shipping service"

systemctl start shipping &>>$LOGFILE

VALIDATE $? "Starting shipping service"

# We need to load the schema. To load schema we need to install mysql client

yum install mysql -y &>>$LOGFILE

# Load Schema

mysql -h mysql.aslamroboshop.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE

VALIDATE $? "Load schema"

# Restart shipping service to reflect schema changes

systemctl restart shipping &>>$LOGFILE

VALIDATE $? "Restarting shipping service"