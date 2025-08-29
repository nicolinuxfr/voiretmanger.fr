#!/bin/bash

# Ce script doit être exécuté sur un nouveau serveur, sous Debian 12.
# PENSEZ À L'ADAPTER EN FONCTION DE VOS BESOINS

GIT="/home/debian/config"

# Nécessaire pour éviter les erreurs de LOCALE par la suite
locale-gen "en_US.UTF-8"
timedatectl set-timezone Europe/Paris

echo "======== Mise à jour initiale ========"
apt update
apt -y upgrade
apt -y dist-upgrade
apt -y install apt-transport-https ca-certificates curl software-properties-common libcap2-bin jq unzip htop cron

echo "======== Nom de domaine ========"
hostnamectl set-hostname voiretmanger.fr

echo "======== Configuration de la sécurité ========"
apt install -y ufw fail2ban
ufw allow ssh
ufw allow http
ufw allow https
ufw enable

tee -a /etc/fail2ban/jail.d/defaults-debian.conf <<EOF
backend = systemd
EOF
systemctl restart fail2ban

echo "======== Installation de Caddy ========"
apt install -y debian-keyring debian-archive-keyring
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
apt -y update
apt -y install caddy

cp -rf $GIT/etc/caddy/Caddyfile /etc/caddy/
chown caddy:caddy /etc/caddy/Caddyfile
chmod 444 /etc/caddy/Caddyfile

systemctl start caddy

usermod -a -G caddy debian

echo "======== Création des dossiers nécessaires ========"

su debian -c 'mkdir ~/backup'
mkdir -p /var/log/caddy
chown -R caddy:caddy /var/log/caddy

echo "======== Installation de PHP ========"
sudo curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt update
apt -y install php8.3 php8.3-{bcmath,cli,curl,fpm,gd,imagick,mbstring,mysql,xml,xmlrpc,zip} imagemagick

# Fichier de configuration
ln -sf $GIT/etc/php/conf.d/*.ini /etc/php/8.3/fpm/conf.d
ln -sf $GIT/etc/php/pool.d/*.conf /etc/php/8.3/fpm/pool.d

systemctl restart php8.3-fpm

usermod -a -G www-data debian

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
                /usr/lib/php/php8.3-fpm-reopenlogs
        endscript
}
EOF

echo "======== Installation de MariaDB ========"
apt -y install mariadb-server

tee -a /etc/mysql/mariadb.conf.d/binlog.cnf <<EOF
[mysqld]
disable_log_bin
EOF

systemctl restart mysql

echo "======== Installation de Forgejo ========"
wget --content-disposition https://code.forgejo.org/forgejo-contrib/-/packages/debian/forgejo-deb-repo/0-0/files/2890
apt install ./forgejo-deb-repo_0-0_all.deb

apt update
apt upgrade
apt -y install forgejo

echo "======== Installation de WP-CLI ========"
# Installation et déplacement au bon endroit
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Fichier de configuration
su debian -c 'ln -s /home/debian/config/home/.wp-cli ~/'

echo "======== Installation de Composer ========"
cd /tmp
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer

echo "======== Installation de Docker ========"
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

mkdir /opt/teslamate
ln -sf $GIT/opt/teslamate/docker-compose.yml /opt/teslamate/docker-compose.yml
git clone https://github.com/jheredianet/Teslamate-CustomGrafanaDashboards.git /opt/teslamate/

mkdir -p /opt/forgejo-runner/data
ln -sf $GIT/opt/forgejo-runner/docker-compose.yml /opt/forgejo-runner/docker-compose.yml
ln -sf $GIT/opt/forgejo-runner/data/config.yml /opt/forgejo-runner/data/config.yml

echo "======== Configuration du SWAP ========"
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo "======== Installation des quelques outils ========"
echo "zsh et oh-my-zsh (Shell 2.0)"
apt-get -y install zsh

su debian -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' 

su debian -c 'ln -sf /home/debian/config/home/.alias ~/.alias'
su debian -c 'ln -sf /home/debian/config/home/.zshrc ~/.zshrc'

chsh -s $(which zsh) debian

# Installation des crons automatiques

## Création des fichiers de log
touch /var/log/backup.log
chown debian:debian /var/log/backup.log

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
tee -a /etc/cron.d/backup <<EOF
0 1 * * * root $GIT/tools/backup.sh > /var/log/backup.log 2>&1
EOF


# Nettoyages
apt-get -y autoremove

# Préparation de la suite

mkdir /var/www
mkdir -p /var/lib/caddy/.local/share/caddy
chown debian:debian /var/www
chown debian:debian /var/lib/caddy/.local/share/caddy


IP=`curl -sS ipecho.net/plain`

echo "\n======== Script d'installation terminé ========\n\n\n"

echo "Ouvrez une nouvelle session avec ce même compte pour bénéficier de tous les changements.\n\n "

echo "Vous pourrez ensuite transférer les données vers ce serveur en utilisant ces commandes depuis le précédent serveur : "

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' /var/www/* debian@$IP:/var/www"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' /var/lib/caddy/.local/share/caddy/* debian@$IP:/var/lib/caddy/.local/share/caddy"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' ~/backup/* debian@$IP:~/backup"

echo "wp --allow-root db export - > ~/dump.sql"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' ~/dump.sql debian@$IP:~/"
