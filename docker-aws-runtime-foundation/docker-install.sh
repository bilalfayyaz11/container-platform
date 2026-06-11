#!/bin/bash
set -eux

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

docker run -d \
  --name container-health-page \
  --restart unless-stopped \
  -p 80:80 \
  nginx:alpine
