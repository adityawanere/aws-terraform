#!/bin/bash

# Update system packages
sudo apt-get update -y

# Install Apache2
sudo apt-get install apache2 -y

# Enable and start Apache2 service
sudo systemctl enable apache2
sudo systemctl start apache2

# Create a basic HTML page
echo "<html><h1>Welcome to My EC2 Website!</h1></html>" | sudo tee /var/www/html/index.html

# Set permissions (optional but good practice)
sudo chown -R www-data:www-data /var/www/html
