#!/bin/bash

set -e

echo ">>> Updating package list..."
sudo apt update

echo ">>> Installing MySQL Server..."
# Pre-seed MySQL root password (optional - using blank here for dev)
sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

echo ">>> Securing MySQL installation (optional)..."
# For dev only — no root password set
sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

echo ">>> Restarting MySQL to apply network config..."
sudo systemctl restart mysql

echo ">>> Creating database and user..."
 mysql -u root -e "CREATE DATABASE IF NOT EXISTS devopsdb;"
 mysql -e "CREATE USER IF NOT EXISTS 'mydbuser'@'%' IDENTIFIED BY 'Demo@123';"
 mysql -e "GRANT ALL PRIVILEGES ON devopsdb.* TO 'mydbuser'@'%';"
 mysql -e "FLUSH PRIVILEGES;"

echo ">>> MySQL provisioning complete. Database 'devopsdb' with user 'mydbuser' is ready."
