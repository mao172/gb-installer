#! /bin/sh

set -x

yum install -y httpd

echo "ProxyPass /gitbucket ajp://localhost:8009/gitbucket" >> /etc/httpd/conf.d/httpd-proxy.conf

systemctl enable httpd
systemctl restart httpd

