# Product Management System - Midterm Project

This project is a Product Management (Product Admin) application built using Node.js, Express, and EJS. The application supports flexible data storage (MongoDB or In-memory) and includes a built-in automated deployment workflow for Ubuntu.

## Key Features

- **Product Management (CRUD):** Add, Edit, Delete, and List products.
- **Image Uploads:** Product image handling using Multer.
- **Automatic Data Source Switching:** Automatically uses MongoDB if a connection is available; otherwise, it falls back to an In-memory database.
- **Nginx & SSL Integration:** Configured as a Reverse Proxy with automated SSL certificate setup via Certbot.
- **Versatile Deployment:** Supports running directly with PM2 or containerized via Docker.

## System Requirements

- **Operating System:** Ubuntu (22.04 LTS recommended).
- **Required Ports:**
  - `80`: Web traffic (HTTP).
  - `443`: Secure web traffic (HTTPS - after SSL setup).
  - `22`: SSH access for administration.

### Domain & DNS Preparation (Crucial)

Before running the deployment script, you **must** have a domain name ready:

- **A Record Configuration:** Access your domain's DNS management panel and point the @ record (or a subdomain) to the **Public IP** of your Ubuntu server.
- **Verify Connectivity:** Ensure that running ping yourdomain.com returns your server's IP address.
- **Purpose:** The script uses this domain to:
  - Configure the server_name in Nginx.
  - Register a free SSL certificate from Let's Encrypt via Certbot. If the domain is not pointing to the server IP, the SSL registration will fail.

## Local Installation & Development

Requirement: Node.js 16+ (or compatible version) and `npm`.

Environment File: The application uses a .env file for configuration. A template is provided in the repository (.env.example):

```
PORT=3000
MONGO_URI=mongodb://localhost:27017/products_db
```

### 1\. Install Dependencies

Navigate to the project directory and install the required packages:

```
npm install
```

### 2\. Start the Server

Production Mode:

```
npm start
```

Development Mode (with auto-reload):

```
npm run dev
```

### 3\. Access the Application

After starting the server, open your browser and navigate to:

http://localhost:3000/

The user interface will display a list of products and provide functionalities to add, edit, and delete products.

## Installation & Deployment Guide

### 1\. Clone the Repository

First, clone the repository to your server:

```
git clone <git@github.com>:vuhaipro2707/Midterm_Software_Deployment_Operations_And_Maintainance.git
cd Midterm_Software_Deployment_Operations_And_Maintainance
```

### 2\. Environment Setup

Use the setup.sh script to automatically install Node.js, MongoDB, Nginx, Docker, and configure SSL:

```
chmod +x scripts/setup.sh
sudo ./scripts/setup.sh
```

**Information required when running the script:**

- **Deployment Domain:** Enter the domain name you prepared (e.g., myapp.com or api.yourdomain.site). If left blank, it defaults to localhost (not recommended for SSL usage).
- **Email:** Enter a valid email address to receive SSL certificate expiration notifications from Let's Encrypt.

### 3\. Choose Deployment Method

#### Option A: Traditional Deployment (Using PM2)

This method runs the app directly on the host OS.

```
# Install dependencies
npm install
# Start the application with PM2
sudo pm2 start main.js --name "product-app"
# Monitor status
sudo pm2 status
```

#### Option B: Docker Deployment (Recommended)

This method isolates the application and database into containers.

```
# Start services (App + MongoDB) in background mode
sudo docker-compose -f docker-compose-prod.yml up -d
# Check running containers
sudo docker ps
```

## Project Structure

- controllers/: Business logic handling.
- models/: MongoDB schema definitions.
- public/: Static assets (CSS, JS, Images, Uploads).
- routes/: API and UI route definitions.
- services/: Data source abstraction layer.
- views/: EJS template files for the UI.
- nginx/: Nginx configuration templates.
- Dockerfile & docker-compose\*.yml: Containerization configurations.
