#!/bin/sh

# Ce script doit être exécuté sur un nouveau serveur, avec Ubuntu 16.06.
# PENSEZ À L'ADAPTER EN FONCTION DE VOS BESOINS

# Nécessaire pour éviter les erreurs de LOCALE par la suite
locale-gen "fr_FR.UTF-8"


echo "======== Mise à jour initiale ========"
apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade

echo "======== Création des dossiers nécessaires ========"
mkdir ~/backup
mkdir -p /etc/caddy
chown -R root:www-data /etc/caddy
mkdir -p /etc/ssl/caddy
chown -R root:www-data /etc/ssl/caddy
chmod 0770 /etc/ssl/caddy
mkdir -p /var/log/caddy
chown -R www-dataCor:www-data /var/log/caddy
mkdir /var/www
chown www-data:www-data /var/www
chmod 555 /var/www
mkdir -p /var/www/voiretmanger.fr
mkdir -p /var/www/files.voiretmanger.fr

# Création du bon utilisateur avec les bons paramètres (cf https://github.com/mholt/caddy/tree/master/dist/init/linux-systemd)
deluser www-data
groupadd -g 33 www-data
useradd \
  -g www-data --no-user-group \
  --home-dir /var/www --no-create-home \
  --shell /usr/sbin/nologin \
  --system --uid 33 www-data

echo "======== Installation de PHP 7.2 ========"
add-apt-repository -y ppa:nilarimogard/webupd8
add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get -y install launchpad-getkeys
apt-get -y install php7.2-fpm php7.2-mysql php7.2-curl php7.2-gd php7.2-mbstring php7.2-xml php7.2-xmlrpc
launchpad-getkeys

# Fichier de configuration
ln -sf ~/config/etc/php/7.2/fpm/php.ini /etc/php/7.2/fpm/php.ini

systemctl restart php7.2-fpm

echo "======== Installation de MariaDB 10.2 ========"
apt-get -y install software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository -y 'deb [arch=amd64,i386,ppc64el] http://mariadb.mirrors.ovh.net/MariaDB/repo/10.2/ubuntu xenial main'
apt-get update
apt-get -y install mariadb-server

echo "======== Installation de Caddy ========"
curl https://getcaddy.com | bash -s personal
chown root:root /usr/local/bin/caddy
chmod 755 /usr/local/bin/caddy

# Correction autorisations pour utiliser les ports 80 et 443
setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

# Fichier de configuration
cp ~/config/etc/caddy/Caddyfile /etc/caddy/
chown www-data:www-data /etc/caddy/Caddyfile
chmod 444 /etc/caddy/Caddyfile

# Création du service
systemctl enable ~/config/etc/systemd/system/caddy.service

echo "======== Installation de WP-CLI ========"
# Installation et déplacement au bon endroit
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Fichier de configuration
ln -s ~/config/home/.wp-cli ~/

echo "======== Installation des quelques outils ========"
echo "Micro (éditeur de documents)"
cd /usr/local/bin; curl https://getmic.ro | bash

echo "htop (monitoring)"
apt-get install htop

echo "goaccess (analyse de logs)"
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -
apt-get update
apt-get -y install goaccess

echo "zsh et oh-my-zsh (Shell 2.0)"
apt-get -y install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh)" -s --batch || {
  echo "Could not install Oh My Zsh" >/dev/stderr
  exit 1
}
ln -s ~/config/home/.alias ~/.alias
ln -sf ~/config/home/.zshrc ~/.zshrc

# Configuration de zsh comme défaut pour l'utilisateur 
sudo -i -u nicolas chsh -s $(which zsh)

# Installation des crons automatiques
cp ~/config/etc/cron.d/perso /etc/cron.d/
chmod 644 /etc/cron.d/perso

# Nettoyages et correction permissions
apt-get -y autoremove
chown -R nicolas:nicolas /home/nicolas/.*

# Préparation de la suite
IP=`curl -sS ipecho.net/plain`

echo "\n======== Script d'installation terminé ========\n"
echo "Ouvrez une nouvelle session avec ce même compte pour bénéficier de tous les changements.\n "
echo "Vous pourrez ensuite transférer les données vers ce serveur en utilisant ces commandes depuis le précédent serveur : \n"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e \"ssh -T -o Compression=no -x\" CHEMIN/FICHIERS/* root@$IP:/var/www\n"

echo "Par sécurité, désactivez l'accès distant en root sur ce serveur après le transfert."
