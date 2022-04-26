#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
cat /etc/system-release
sudo yum install -y httpd mariadb-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo yum list installed httpd mariadb-server php-mysqlnd
sudo systemctl start mariadb
PASS=$(echo "$(date | md5sum)")
#sudo /usr/bin/mysqladmin -u root password 'FjXykSmJfA'
sudo /usr/bin/mysqladmin -u root password "$PASS"
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php
cp -r wordpress/* /var/www/html/
rm -r wordpress
sed -n '151p;151q' /etc/httpd/conf/httpd.conf | sudo sed -i 's/None/All/g' /etc/httpd/conf/httpd.conf #Options Indexes FollowSymLinks
sudo sed -i 's/username_here/wordpress_user/g' /var/www/html/wp-config.php
sudo sed -i "s/password_here/$PASS/g" /var/www/html/wp-config.php
sudo sed -i 's/database_name_here/wordpress/g' /var/www/html/wp-config.php
cd /var/www/html/
find . -name wp-config.php -print | while read line
do
    curl http://api.wordpress.org/secret-key/1.1/salt/ > wp_keys.txt
    sed -i.bak -e '/put your unique phrase here/d' -e \
    '/AUTH_KEY/d' -e '/SECURE_AUTH_KEY/d' -e '/LOGGED_IN_KEY/d' -e '/NONCE_KEY/d' -e \
    '/AUTH_SALT/d' -e '/SECURE_AUTH_SALT/d' -e '/LOGGED_IN_SALT/d' -e '/NONCE_SALT/d' $line
    cat wp_keys.txt >> $line
    rm wp_keys.txt
done
sudo systemctl start mariadb
#mysql -u root -pFjXykSmJfA
mysql -u root -p"$PASS" -e "CREATE USER wordpress_user@localhost IDENTIFIED BY '$PASS';"
mysql -u root -p"$PASS" -e "CREATE DATABASE wordpress;"
mysql -u root -p"$PASS" -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpress_user@localhost;"
mysql -u root -p"$PASS" -e "FLUSH PRIVILEGES;"
sudo yum -y install php-gd
sudo chown -R apache:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl restart httpd
sudo systemctl enable httpd
sudo systemctl enable mariadb
sudo yum install -y mod_ssl
cd /etc/pki/tls/certs
sudo ./make-dummy-cert localhost.crt
sudo sed -i 's/SSLCertificateKeyFile/#SSLCertificateKeyFile/g' /etc/httpd/conf.d/ssl.conf
sudo systemctl restart httpd
------------------------------------------------
cd /home/ec2-user
yum install gcc pcre-devel tar make -y
wget https://www.haproxy.org/download/2.2/src/haproxy-2.2.17.tar.gz
tar xzvf haproxy-2.2.17.tar.gz
rm haproxy-2.2.17.tar.gz
mv haproxy-2.2.17 /usr/share/doc
cd /usr/share/doc/haproxy-2.2.17/
make TARGET=linux-glibc
make install
mkdir -p /etc/haproxy
mkdir -p /var/lib/haproxy 
touch /var/lib/haproxy/stats
sudo ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy
cp examples/haproxy.init /etc/init.d/haproxy
chmod 755 /etc/init.d/haproxy
systemctl daemon-reload
chkconfig haproxy on
useradd -r haproxy

#yum install haproxy -y
#systemctl enable haproxy
#systemctl start haproxy
#cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy_old.cfg

#SET PASSWORD FOR 'root'@'localhost' = PASSWORD('test');
#show databases; #Посмотреть какие есть БД
#SELECT user,host FROM mysql.user;  #Посмотреть какие есть пользователи БД
