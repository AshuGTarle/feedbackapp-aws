#!/bin/bash
# FeedbackApp - Web Server Setup Script
# This script installs and configures Apache on Amazon Linux 2023.

# Update system packages
sudo dnf update -y

# Install Apache (httpd)
sudo dnf install -y httpd

# Start Apache now
sudo systemctl start httpd

# Enable Apache on boot
sudo systemctl enable httpd

# Create a test webpage
echo "<h1>Welcome to FeedbackApp Project - Web Server on AWS</h1>" | sudo tee /var/www/html/index.html

# Print status
echo "✅ Web server setup complete. Visit your Public EC2 IP or Load Balancer DNS in a browser."
