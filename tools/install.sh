#!/bin/bash

# Ce script doit être exécuté sur un nouveau serveur, avec Ubuntu 20.04 LTS.
# PENSEZ À L'ADAPTER EN FONCTION DE VOS BESOINS

# Nécessaire pour éviter les erreurs de LOCALE par la suite
locale-gen "en_US.UTF-8"
timedatectl set-timezone Europe/Paris

echo "======== Mise à jour initiale ========"
apt update
apt -y upgrade
apt -y dist-upgrade
apt -y install libcap2-bin jq

echo "======== Installation de Caddy ========"
echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" \
    | sudo tee -a /etc/apt/sources.list.d/caddy-fury.list
apt update
apt install caddy

cp -rf ~/config/etc/caddy/Caddyfile /etc/caddy/
chown caddy:caddy /etc/caddy/Caddyfile
chmod 444 /etc/caddy/Caddyfile

systemctl start caddy

echo "======== Création des dossiers nécessaires ========"

mkdir ~/backup
mkdir -p /var/log/caddy
chown -R caddy:caddy /var/log/caddy

echo "======== Installation de PHP 7.4 ========"
apt update
apt -y install php-cli php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-json php-xmlrpc php-zip php-bcmath imagemagick php-imagick

# Fichier de configuration
ln -sf ~/config/etc/php/conf.d/*.ini /etc/php/7.4/fpm/conf.d
ln -sf ~/config/etc/php/pool.d/*.conf /etc/php/7.4/fpm/pool.d

systemctl restart php7.4-fpm

echo "======== Installation de MySQL ========"
apt-get -y install mysql-server

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
ln -s ~/config/home/.wp-cli ~/

echo "======== Installation des quelques outils ========"
echo "zsh et oh-my-zsh (Shell 2.0)"
apt-get -y install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh)" -s --batch || {
  echo "Could not install Oh My Zsh" >/dev/stderr
  exit 1
}
ln -s ~/config/home/.alias ~/.alias
ln -sf ~/config/home/.zshrc ~/.zshrc

# Configuration de zsh comme défaut pour l'utilisateur 
chsh -s $(which zsh)

# Installation des crons automatiques

## Création des fichiers de log
touch /var/log/mysql/backup.log

### Création du cron
tee -a /etc/cron.d/refurb <<EOF
0 0 * * * root ~/config/tools/db.sh > /var/log/mysql/backup.log 2>&1
EOF


# Nettoyages
apt-get -y autoremove

# Préparation de la suite
IP=`curl -sS ipecho.net/plain`

echo "\n======== Script d'installation terminé ========\n\n\n"

echo "Ouvrez une nouvelle session avec ce même compte pour bénéficier de tous les changements.\n\n "

echo "Vous pourrez ensuite transférer les données vers ce serveur en utilisant ces commandes depuis le précédent serveur : \n"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' /var/www/* root@$IP:/var/www\n"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' /var/lib/caddy/.local/share/caddy/* root@$IP:/var/lib/caddy/.local/share/caddy\n"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' ~/backup/* root@$IP:~/backup\n"

echo "wp --allow-root db export - > ~/dump.sql\n"

echo "rsync -aHAXxv --numeric-ids --delete --progress -e 'ssh -T -o Compression=no -x' ~/dump.sql root@$IP:~/\n"
