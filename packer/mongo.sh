#!/bin/bash
if [ "$(whoami)" != "root" ]
then
    sudo su -s "$0"
    exit
fi
cat <<EOF >> /etc/yum.repos.d/mongodb-org-4.2.repo
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
EOF
yum install -y mongodb-org
mkdir /etc/systemd/system/mongod.service.d
cat <<EOF >> /etc/systemd/system/mongod.service.d/mongod.conf
[Service]
LimitFSIZE=infinity
LimitCPU=infinity
LimitAS=infinity
LimitMEMLOCK=infinity
LimitNOFILE=64000
LimitNPROC=64000
EOF
systemctl enable mongod
systemctl start mongod
