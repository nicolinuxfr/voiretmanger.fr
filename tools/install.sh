#!/bin/sh

# Ce script doit être exécuté sur un nouveau serveur, avec Ubuntu 16.06.
# PENSEZ À L'ADAPTER EN FONCTION DE VOS BESOINS

# Téléchargements
echo "======== Mise à jour initiale ========"
apt-get update
apt-get upgrade
apt-get dist-upgrade

echo "======== Installation de PHP 7.1 ========"
add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get install php7.1-fpm php7.1-mysql php7.1-curl php7.1-gd php7.1-mbstring php7.1-mcrypt php7.1-xml php7.1-xmlrpc
systemctl restart php7.1-fpm

echo "======== Installation de MariaDB 10.2 ========"
apt-get install software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mariadb.mirrors.ovh.net/MariaDB/repo/10.2/ubuntu xenial main'
apt update
apt install mariadb-server

echo "======== Installation de Caddy ========"
curl https://getcaddy.com | bash -s personal

echo "======== Installation des quelques outils ========"
echo "Micro (éditeur de documents)"
cd /usr/local/bin; curl https://getmic.ro | sudo bash

echo "htop (monitoring)"
apt-get install htop

echo "goaccess (analyse de logs)"
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -
apt-get update
apt-get install goaccess

echo "======== Création des dossiers nécessaires ========"
mkdir -p /etc/caddy/


echo "======== Installation des fichiers de configuration ========"
ln -s ~/config/etc/caddy/Caddyfile /etc/caddy/Caddyfile
ln -sf ~/config/etc/php/7.1/fpm/php.ini /etc/php/7.1/fpm/php.ini
ln -sf ~/config/etc/php/7.1/fpm/php-fpm.conf /etc/php/7.1/fpm/php-fpm.conf


echo "======== Création du service pour Caddy ========"
systemctl enable /home/config/etc/systemd/system/caddy.service

# À la fin, puisque oh-my-zsh interrompt le processus
echo "zsh et oh-my-zsh (Shell 2.0)"
apt-get install zsh
ln -s ~/config/home/.alias ~/.alias
ln -sf ~/config/home/.zshrc ~/.zshrc
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"