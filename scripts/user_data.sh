#!/bin/bash
mkdir /srv/dockercfg
timedatectl set-timezone America/Fortaleza

# Configurações do Docker e Docker Compose
yum update 
yum install -y docker

systemctl start docker.service
systemctl enable docker.service
sudo usermod -aG docker ${USER}

curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose && chmod +x /usr/bin/docker-compose

# Configuração e instalação do NFS
yum install amazon-efs-utils -y 
systemctl start nfs-utils.service
systemctl enable nfs-utils.service
mkdir /efs

sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0e4b7f8703ea99463.efs.us-east-1.amazonaws.com:/ /efs
mkdir /efs/wpArchive

cat <<EOT > /srv/dockercfg/docker-compose.yaml
version: '3'
services:
  wordpress:
    image: wordpress:latest
    volumes:
      - /efs/wpArchive:/var/www/html
    ports:
      - "80:80"
    restart: always
    container_name: wordpress
    environment:
      WORDPRESS_DB_HOST: wpdata.cjsr5jsdfqmu.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wpdata
EOT

docker-compose -f /srv/dockercfg/docker-compose.yaml up -d
