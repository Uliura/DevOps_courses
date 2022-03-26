#!/bin/bash
sudo yum update -y

sudo yum install httpd -y
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
sudo yum-config-manager --disable remi-php54
sudo yum-config-manager --enable remi-php73
sudo yum install php php-mysqlnd -y
sudo systemctl restart httpd.service

wget http://repo.mysql.com/mysql57-community-release-el7.rpm
sudo rpm -ivh mysql57-community-release-el7.rpm -y
sudo yum update -y
sudo rpm --import http://repo.mysql.com/RPM-GPG-KEY-mysql-2022
sudo yum install mysql-server -y
sudo systemctl start mysqld

curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install nodejs -y
