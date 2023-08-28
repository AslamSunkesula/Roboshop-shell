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


curl -sL https://rpm.nodesource.com/setup_lts.x | bash

VALIDATE $? "Setting up NPM Source"

yum install nodejs -y

VALIDATE $? "Installing NodeJS"

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


#Download the application code to created app directory.


curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>>$LOGFILE

VALIDATE $? "downloading catalogue artifact"

cd /app  &>>$LOGFILE

VALIDATE $? "Moving into app directory"


unzip /tmp/catalogue.zip  &>>$LOGFILE

VALIDATE $? "unzipping catalogue"


npm install  &>>$LOGFILE

VALIDATE $? "Installing dependencies"


# give full path of catalogue.service because we are inside /app
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE


VALIDATE $? "copying catalogue.service"


systemctl daemon-reload  &>>$LOGFILE

VALIDATE $? "daemon reload"

systemctl enable catalogue  &>>$LOGFILE

VALIDATE $? "Enabling Catalogue"

systemctl start catalogue  &>>$LOGFILE
 
VALIDATE $? "Starting Catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying mongo repo"

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing mongo client"


mongo --host mongodb.joindevops.online </app/schema/catalogue.js &>>$LOGFILE

VALIDATE $? "loading catalogue data into mongodb"


