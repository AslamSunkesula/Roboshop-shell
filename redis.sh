#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
script_name=$0
LOGFILE=$LOGSDIR/$script_name-$DATE.log

#LOGFILE=/tmp/$script_name-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

VALIDATE() {

    if [ $? -ne 0 ]; then

        echo " $2 is ...... $R Failure"

    else

        echo " $2 is .......$G Success "
    fi

}

if [ $USERID -ne 0 ]; then

    echo
    " $R Error : Please run the script with root access $N"
    exit 1

fi

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOGFILE

VALIDATE $? "Installing the redis repro"

yum module enable redis:remi-6.2 -y &>>$LOGFILE

VALIDATE $? "Enabling the Redies 6.2"

yum install redis -y &>>$LOGFILE

VALIDATE $? "Installing the redis"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &
/etc/redis/redis.conf &>>$LOGFILE

VALIDATE $? "Allowing the remote connections to redies"

systemctl enable redis &>>$LOGFILE

VALIDATE $? "Enabling the redies"

systemctl start redis &>>$LOGFILE

VALIDATE $? "Starting the redies"
