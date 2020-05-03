#!/bin/bash -x
if [ "$(whoami)" != "root" ]
then
    sudo su -s "$0"
    exit
fi

amazon-linux-extras install epel -y
yum install nginx -y

systemctl enable nginx
systemctl start nginx

cp /var/packer_temp/* /usr/share/nginx/html/
