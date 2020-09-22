#!/bin/bash

# Ce script doit être exécuté après le script "install.sh" ET APRÈS AVOIR TRANSFÉRÉ LES FICHIERS dans /var/www/ et les clés SSH dans /var/lib/caddy/.local/share/caddy/
# Il considère aussi que la base de données à importer est à la racine du dossier utilisateur : ~/dump.sql

HOME="/home/ubuntu"

echo "Préparation de la base de données"

mysql_secure_installation

echo "Saisir le mot de passe root mysql : "
read passwdroot

tee -a $HOME/.my.cnf <<EOF
[client]
user=root
password="$passwdroot"
host=localhost
EOF
chmod 0600 $HOME/.my.cnf

echo "Saisir le mot de passe de la db : "
read passwddb

mysql -u root -p$passwdroot <<EOF
CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER 'voiretmanger'@'localhost' IDENTIFIED BY '$passwddb';
GRANT ALL ON wordpress.* TO 'voiretmanger'@'localhost';
USE wordpress;
SOURCE $HOME/dump.sql;
FLUSH PRIVILEGES;
EOF

service mysql restart

echo "Réparation des permissions"
chown -R caddy:caddy /var/www
chmod -R g+w /var/www
chmod -R 755 /var/www/voiretmanger.fr
chown -R caddy:caddy /var/lib/caddy
chmod -R 770 /var/lib/caddy/.local/share/caddy

echo "Démarrage de Caddy"
systemctl daemon-reload
service caddy start
