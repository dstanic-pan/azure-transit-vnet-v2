#cloud-config

runcmd:
  - sudo apt-get update -y
  - sudo apt-get install apache2 -y
  - sudo sed -i 's/#D8DBE2/#4286F4/g' /var/www/html/index.html
  - sudo sed -i 's/Apache2 Ubuntu Default Page/Spoke Web Server 1/g' /var/www/html/index.html
  - sudo sed -i 's/It works!/This is showing the Apache page hosted on the Spoke Web Server/g' /var/www/html/index.html
  - sudo service apache2 restart
