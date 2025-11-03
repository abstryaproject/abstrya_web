#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(pwd)"
WEB_ROOT="/var/www/abstryacloud"
DB_NAME="abstryacloud"

echo "=== Abstrya Cloud Installer ==="

read -p "MySQL root user [root]: " DB_ROOT_USER
DB_ROOT_USER=${DB_ROOT_USER:-root}
read -s -p "MySQL root password [toor]: " DB_ROOT_PASS
echo

# Create database and tables
echo "Creating database and tables..."
mysql -u "$DB_ROOT_USER" -p"$DB_ROOT_PASS" <<SQL
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE $DB_NAME;
SOURCE $ROOT_DIR/site_schema.sql;
SQL

# Ensure website destination
echo "Creating web root at $WEB_ROOT"
sudo mkdir -p "$WEB_ROOT"
sudo chown "$USER":"$USER" "$WEB_ROOT"

# Copy website and admin content
echo "Copying website files..."
cp -r "$ROOT_DIR/root/website/." "$WEB_ROOT/"
echo "Copying docs files..."
cp -r "$ROOT_DIR/root/docs/." "$WEB_ROOT/docs/"

# Create config.php
read -p "OpenStack Keystone/controller IP (for API calls) [127.0.0.1]: " CONTROLLER_IP
CONTROLLER_IP=${CONTROLLER_IP:-127.0.0.1}
read -p "Admin Email for Let's Encrypt [admin@abstryacloud.local]: " ADMIN_EMAIL
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@abstryacloud.local}
cat > "$WEB_ROOT/config.php" <<PHP
<?php
// generated config
return [
  'db' => [
    'host' => '127.0.0.1',
    'name' => '$DB_NAME',
    'user' => '$DB_ROOT_USER',
    'pass' => '$DB_ROOT_PASS',
  ],
  'keystone' => [
    'url' => 'http://$CONTROLLER_IP:5000/v3',
    'controller_ip' => '$CONTROLLER_IP'
  ],
  'site' => [
    'domain' => 'abstryacloud.local',
    'admin_email' => '$ADMIN_EMAIL'
  ]
];
PHP

# Nginx config (simple)
NGINX_CONF="/etc/nginx/sites-available/abstryacloud.conf"
sudo bash -c "cat > $NGINX_CONF" <<NGINX
server {
    listen 80;
    server_name abstryacloud.local;

    root $WEB_ROOT;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht { deny all; }
}
NGINX

sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/abstryacloud.conf
sudo nginx -t
sudo systemctl reload nginx

read -p "Enable HTTPS via Certbot for abstryacloud.local? [y/N]: " ENABLE_HTTPS
if [[ "${ENABLE_HTTPS,,}" == "y" ]]; then
  sudo apt-get update
  sudo apt-get install -y certbot python3-certbot-nginx
  sudo certbot --nginx -d abstryacloud.local --non-interactive --agree-tos -m "$ADMIN_EMAIL"
fi

echo "Installer finished. Visit http://abstryacloud.local to verify."