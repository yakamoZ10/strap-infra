#!/bin/bash

echo '==============================================='
echo '          Updating system packages             '
echo '==============================================='
sudo sudo dnf update -y
echo '==============================================='
echo '             Installing Docker                 '
echo '==============================================='
sudo sudo dnf install docker -y
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo systemctl enable docker.socket
sudo systemctl enable containerd
echo '==============================================='
echo '             Installing Docker Compose         '
echo '==============================================='
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version
echo '==============================================='
echo '             Installing Node.js                '
echo '==============================================='
# Add Node.js 18 LTS repository
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install nodejs -y
node -v
npm -v
echo '==============================================='
echo '             Creating Docker Compose file      '
echo '==============================================='
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app
cat <<EOF > docker-compose.yml
version: "3"
services:
  strapi:
    container_name: strapi
    image: 340752798883.dkr.ecr.eu-central-1.amazonaws.com/ultralinkk/strapi:latest
    restart: unless-stopped
    env_file: .env
    environment:
      DATABASE_CLIENT: ${DATABASE_CLIENT}
      DATABASE_HOST: ${DATABASE_HOST}
      DATABASE_PORT: ${DATABASE_PORT}
      DATABASE_NAME: ${DATABASE_NAME}
      DATABASE_USERNAME: ${DATABASE_USERNAME}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
      ADMIN_JWT_SECRET: ${ADMIN_JWT_SECRET}
      APP_KEYS: ${APP_KEYS}
      NODE_ENV: ${NODE_ENV}
    volumes:
      - ./config:/opt/app/config
      - ./src:/opt/app/src
      - ./package.json:/opt/package.json
      - ./yarn.lock:/opt/yarn.lock
      - ./.env:/opt/app/.env
      - ./public/uploads:/opt/app/public/uploads
    ports:
      - "80:1337"

networks:
  strapi:
    name: Strapi
    driver: bridge
EOF
echo '==============================================='
echo '             Writing the env file              '
echo '==============================================='
cd /home/ec2-user/app
cat <<EOF > .env
DATABASE_CLIENT=
DATABASE_HOST=
DATABASE_PORT=
DATABASE_NAME=
DATABASE_USERNAME=
DATABASE_PASSWORD=
JWT_SECRET=
ADMIN_JWT_SECRET=
APP_KEYS=
NODE_ENV=
EOF