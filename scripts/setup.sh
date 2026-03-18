#!/bin/bash

# =================================================================
# Script Name: setup.sh
# Purpose: Prepare Ubuntu environment for Node.js Application (Phase 1)
# =================================================================

echo "Nhập tên miền deployment:"
read DOMAIN
DOMAIN=${DOMAIN:-localhost} 

echo "Nhập Email để nhận thông báo SSL:"
read EMAIL
EMAIL=${EMAIL:-admin@example.com}

# 1. Cập nhật danh sách gói phần mềm hệ thống
sudo apt-get update -y
sudo apt-get install -y gnupg curl git

# 2. Cài đặt Node.js (phiên bản LTS)

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g pm2

# 3. Cài đặt MongoDB
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

sudo apt-get update -y
sudo apt-get install -y mongodb-org

sudo systemctl start mongod
sudo systemctl enable mongod

# 4. Tạo thư mục cần thiết

mkdir -p ../logs ../uploads ../data
chmod -R 755 ../logs ../uploads ../data

# 5. Nginx setup
sudo apt-get install -y nginx certbot python3-certbot-nginx
sudo cp ../nginx/myapp.conf /etc/nginx/sites-available/myapp
sudo sed -i "s|^\([[:space:]]*\)server_name .*;|\1server_name $DOMAIN;|g" /etc/nginx/sites-available/myapp
sudo ln -sf /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

# 6. Cài đặt Certbot và cấu hình SSL
sudo certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m ${EMAIL}

# 7. Cài đặt Docker và Docker Compose
sudo apt install docker.io docker-compose -y

# Thông báo kết quả
echo "---------------------------------------------------"
echo "Setup hoàn tất! MongoDB và Node.js đã sẵn sàng."
echo "MongoDB status: $(systemctl is-active mongod)"
echo "Nginx đã được cấu hình với SSL cho domain: ${DOMAIN}"
echo "---------------------------------------------------"