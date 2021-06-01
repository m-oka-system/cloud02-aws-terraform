#!/bin/bash

# Variables
AWS_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone) && echo $AWS_AVAIL_ZONE
AWS_REGION=$(echo "$AWS_AVAIL_ZONE" | sed 's/[a-z]$//') && echo $AWS_REGION
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) && echo $INSTANCE_ID
EC2_NAME=$(aws ec2 describe-instances --region $AWS_REGION --instance-id $INSTANCE_ID \
  --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value' --output text) && echo $EC2_NAME

# Install nginx if not installed
nginx -v
if [ "$?" -ne 0 ]; then
  sudo amazon-linux-extras install -y nginx1
  sudo systemctl enable nginx
  sudo systemctl start nginx
fi

# Install mysql client if not installed
mysql --version
if [ "$?" -ne 0 ]; then
  # delete mariadb
  yum list installed | grep mariadb
  sudo yum remove mariadb-libs -y

  # add repo
  sudo yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

  # disable mysql5.7 repo and enable mysql8.0 repo
  sudo yum-config-manager --disable mysql57-community
  sudo yum-config-manager --enable mysql80-community

  # install mysql client
  sudo yum install -y mysql-community-client
fi

# Create index.html
echo "<h1>${EC2_NAME}</h1>" > index.html
sudo mv ./index.html  /usr/share/nginx/html/
