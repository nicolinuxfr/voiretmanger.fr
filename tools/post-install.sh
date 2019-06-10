#!/bin/bash

# Ce script doit être exécuté après le script "install.sh" ET APRÈS AVOIR TRANSFÉRÉ LES FICHIERS dans /var/www/ et les clés SSH dans /etc/ssl/caddy/
# Il considère aussi que la base de données à importer est à la racine du dossier utilisateur : ~/dump.sql

echo "Préparation de la base de données"

echo "Saisir le mot de passe root mysql : "
read passwdroot

# Équivalent automatisé de la commande `mysql_secure_installation`. Source : http://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/

mysql --user=root <<EOF
UPDATE mysql.user SET Password=PASSWORD('$passwdroot') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "Saisir le mot de passe de la db : "
read passwddb

mysql -u root -p$passwdroot <<EOF
CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON wordpress.* TO 'voiretmanger'@'localhost' IDENTIFIED BY '$passwddb';
USE wordpress;
SOURCE /root/dump.sql;
FLUSH PRIVILEGES;
EOF

service mysql restart

echo "Réparation des permissions"
chown -R  www-data:www-data /var/www
chmod -R 555 /var/www
chmod -R 755 /var/www/voiretmanger.fr/wp-content/
chown -R root:www-data /etc/ssl/caddy
chmod -R 0770 /etc/ssl/caddy

echo "Démarrage de Caddy"
systemctl daemon-reload
service caddy start
