#!/bin/bash -x
if [ "$(whoami)" != "root" ]
then
    sudo su -s "$0"
    exit
fi

amazon-linux-extras install epel -y
yum install openvpn -y
cp /var/packer_temp/*server* /var/packer_temp/ca* /var/packer_temp/dh.pem /etc/openvpn/server
cp /var/packer_temp/*client* /var/packer_temp/ca* /var/packer_temp/dh.pem /etc/openvpn/client
rm -rf /var/packer_temp/*

cat <<EOF >> /etc/systemd/system/openvpn.service
[Unit]
Description=OpenVPN Robust And Highly Flexible Tunneling Application
After=network.target

[Service]
Type=notify
PrivateTmp=true
ExecStart=/usr/sbin/openvpn --cd /etc/openvpn/server --config server.conf

[Install]
WantedBy=multi-user.target
EOF

echo "net.ipv4.ip_forward = 1" > /etc/sysctl.conf

systemctl daemon-reload
systemctl enable openvpn

useradd terraform
echo sup3rs3cr37 | passwd --stdin terraform

cat <<EOF >> /etc/sudoers.d/terraform
terraform ALL=(ALL) NOPASSWD:ALL
EOF

usermod -aG openvpn terraform
chown -R terraform:openvpn /etc/openvpn

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/ssh_pwauth:   false/ssh_pwauth:   true/g' /etc/cloud/cloud.cfg
