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
apt-get update -y
apt-get install -y gnupg curl git

# 2. Cài đặt Node.js (phiên bản LTS)

curl -fsSL https://deb.nodesource.com/setup_lts.x | -E bash -
apt-get install -y nodejs npm
npm install -g pm2

# 3. Cài đặt MongoDB
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list

apt-get update -y
apt-get install -y mongodb-org

systemctl start mongod
systemctl enable mongod

# 4. Tạo thư mục cần thiết

mkdir -p ./logs ./uploads ./data
chmod -R 755 ./logs ./uploads ./data

# 5. Nginx setup
apt-get install -y nginx certbot python3-certbot-nginx
cp ./nginx/myapp.conf /etc/nginx/sites-available/myapp
sed -i "s|^\([[:space:]]*\)server_name .*;|\1server_name $DOMAIN;|g" /etc/nginx/sites-available/myapp
ln -sf /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

# 6. Cài đặt Certbot và cấu hình SSL
certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m ${EMAIL}

# 7. Cài đặt Docker và Docker Compose
apt install docker.io docker-compose -y

# 8. Thiết lập tự động khởi động cho các dịch vụ
echo "--- Đang thiết lập tự động bật cho Nginx ---"
systemctl enable nginx
systemctl start nginx

echo "--- Đang thiết lập tự động bật cho PM2 ---"
PM2_STARTUP=$(pm2 startup | grep "env" | sed 's/^[[:space:]]*//')
eval "$PM2_STARTUP"
pm2 save

echo "--- Đang thiết lập tự động bật cho Docker ---"
systemctl enable docker.service
systemctl enable containerd.service

# Thông báo kết quả
echo "---------------------------------------------------"
echo "Setup hoàn tất! MongoDB và Node.js đã sẵn sàng."
echo "MongoDB status: $(systemctl is-active mongod)"
echo "Nginx đã được cấu hình với SSL cho domain: ${DOMAIN}"
echo "Các dịch vụ đã được cấu hình tự động khởi động."
echo "---------------------------------------------------"