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


if [ $USERID -ne 0 ]; then

    echo -e
    " $R Error : Please run the script with root access $N"
    exit 1

fi

VALIDATE() {

    if [ $1 -ne 0 ]; then

        echo -e " $2 is ...... $R Failure"

    else

        echo -e " $2 is .......$G Success "
    fi

}


yum module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling the default version"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Copying MySQL repo" 

yum install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling MySQL"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Staring MySQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "setting up root password"