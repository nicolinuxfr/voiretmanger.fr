#!/bin/bash

# Ce script doit être exécuté sur un nouveau serveur, avec Ubuntu 20.04 LTS.
# PENSEZ À L'ADAPTER EN FONCTION DE VOS BESOINS

GIT="/home/ubuntu/config"

# Nécessaire pour éviter les erreurs de LOCALE par la suite
locale-gen "en_US.UTF-8"
timedatectl set-timezone Europe/Paris

echo "======== Mise à jour initiale ========"
apt update
apt -y upgrade
apt -y dist-upgrade
apt -y install libcap2-bin jq unzip fail2ban


echo "======== Configuration de l'IPv6 ========"

ln -sf $GIT/etc/netplan/51-cloud-init-ipv6.yaml /etc/netplan/
netplan apply


echo "======== Installation de Caddy ========"
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo apt-key add -
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee -a /etc/apt/sources.list.d/caddy-stable.list
apt -y update
apt -y install caddy

cp -rf $GIT/etc/caddy/Caddyfile /etc/caddy/
chown caddy:caddy /etc/caddy/Caddyfile
chmod 444 /etc/caddy/Caddyfile

systemctl start caddy

usermod -a -G caddy ubuntu

echo "======== Création des dossiers nécessaires ========"

su ubuntu -c 'mkdir ~/backup'
mkdir -p /var/log/caddy
chown -R caddy:caddy /var/log/caddy

echo "======== Installation de PHP ========"
add-apt-repository -y ppa:ondrej/php
apt update
apt -y install php8.1 php8.1-{bcmath,cli,curl,fpm,gd,imagick,mbstring,mysql,xml,xmlrpc,zip} imagemagick

# Fichier de configuration
ln -sf $GIT/etc/php/conf.d/*.ini /etc/php/8.1/fpm/conf.d
ln -sf $GIT/etc/php/pool.d/*.conf /etc/php/8.1/fpm/pool.d

systemctl restart php8.1-fpm

usermod -a -G www-data ubuntu

### Logrotate pour les log du pool Caddy
tee -a /etc/logrotate.d/php-caddy <<EOF
/var/log/php-caddy.access.log {
        rotate 12
        weekly
        missingok
        notifempty
        compress
        delaycompress
        postrotate
                /usr/lib/php/php8.0-fpm-reopenlogs
        endscript
}
EOF

echo "======== Installation de MySQL ========"
apt -y install mysql-server

tee -a /etc/mysql/mysql.conf.d/binlog.cnf <<EOF
[mysqld]
disable_log_bin
EOF

systemctl restart mysql

echo "======== Installation de WP-CLI ========"
# Installation et déplacement au bon endroit
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Fichier de configuration
su ubuntu -c 'ln -s $GIT/home/.wp-cli ~/'

echo "======== Installation de Composer ========"
cd /tmp
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer

echo "======== Installation de Docker ========"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt -y install docker-ce docker-compose
systemctl enable docker

mkdir ~/teslamate
ln -sf $GIT/home/teslamate/docker-compose.yml ~/teslamate/docker-compose.yml

echo "======== Configuration du pare-feu ========"
ufw allow ssh
ufw allow http
ufw allow https
ufw enable

echo "======== Configuration du SWAP ========"
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo "======== Installation des quelques outils ========"
echo "zsh et oh-my-zsh (Shell 2.0)"
apt-get -y install zsh

su ubuntu -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' 

su ubuntu -c 'ln -sf $GIT/home/.alias ~/.alias'
su ubuntu -c 'ln -sf $GIT/home/.zshrc ~/.zshrc'

chsh -s $(which zsh) ubuntu

# Installation des crons automatiques

## Création des fichiers de log
touch /var/log/mysql/backup.log
chown ubuntu:ubuntu /var/log/mysql/backup.log

### Logrotate pour les log de backup
tee -a /etc/logrotate.d/backup <<EOF
/var/log/backup.log {
    rotate 6
    daily
    missingok
    dateext
    copytruncate
    notifempty
    compress
}
EOF

### Création du cron
tee -a /etc/cron.d/refurb <<EOF
0 0 * * * ubuntu $GIT/tools/backup.sh > /var/log/mysql/backup.log 2>&1
EOF


# Nettoyages
apt-get -y autoremove

# Préparation de la suite

mkdir /var/www
mkdir -p /var/lib/caddy/.local/share/caddy
chown ubuntu:ubuntu /var/www
chown ubuntu:ubuntu /var/lib/caddy/.local/share/caddy


IP=`curl -sS ipecho.net/plain`

echo "\n======== Script d'installation terminé ========\n\n\n"

echo "Ouvrez une nouvelle session avec ce même compte pour bénéficier de tous les changements.\n\n "

echo "Vous pourrez ensuite transférer les données vers ce serveur en utilisant ces commandes depuis le précédent serveur : \n"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' /var/www/* root@$IP:/var/www\n"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' /var/lib/caddy/.local/share/caddy/* root@$IP:/var/lib/caddy/.local/share/caddy\n"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' ~/backup/* root@$IP:~/backup\n"

echo "wp --allow-root db export - > ~/dump.sql\n"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' ~/dump.sql root@$IP:~/\n"
