#!/bin/bash

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



cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied the mongodb repo into yum.repos directory"

yum install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Installing the mongodb"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabling the mongod"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting the mongod"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Edited the mongod.conf"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarted the mongod"
