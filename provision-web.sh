#!/bin/bash

set -e

echo ">>> Updating package list..."
sudo apt update

echo ">>> Installing Apache and PHP..."
sudo apt install -y apache2 php libapache2-mod-php php-mysql unzip wget

echo ">>> Enabling Apache mod_rewrite..."
sudo a2enmod rewrite

echo ">>> Setting up WordPress directory..."
sudo mkdir -p /var/www/wordpress
sudo chown -R www-data:www-data /var/www/wordpress

echo ">>> Downloading WordPress..."
wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
tar -xzf /tmp/wordpress.tar.gz -C /tmp
sudo rsync -av /tmp/wordpress/ /var/www/wordpress/

echo ">>> Setting permissions..."
sudo chown -R www-data:www-data /var/www/wordpress
sudo find /var/www/wordpress -type d -exec chmod 755 {} \;
sudo find /var/www/wordpress -type f -exec chmod 644 {} \;

echo ">>> Creating Apache Virtual Host for WordPress..."
cat <<EOF | sudo tee /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/wordpress
    ServerName wordpress.local

    <Directory /var/www/wordpress>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/wordpress_error.log
    CustomLog \${APACHE_LOG_DIR}/wordpress_access.log combined
</VirtualHost>
EOF

echo ">>> Enabling WordPress site..."
sudo a2ensite wordpress.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2

echo ">>> Configuring WordPress wp-config.php..."
cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
sed -i "s/database_name_here/wordpress_db/" /var/www/wordpress/wp-config.php
sed -i "s/username_here/wp_user/" /var/www/wordpress/wp-config.php
sed -i "s/password_here/secret123/" /var/www/wordpress/wp-config.php
sed -i "s/localhost/192.168.56.11/" /var/www/wordpress/wp-config.php

echo ">>> WordPress setup complete. Access via http://192.168.56.10/"