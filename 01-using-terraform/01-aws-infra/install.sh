#!/bin/bash
sudo apt-get update -y
sudo apt-get install apache2 -y
echo "<h1>Welcome to Learning Terraform Program</h1>"  >  /var/www/html/check.html