#!/bin/sh

# Ce script doit être exécuté après le script "install.sh" ET APRÈS AVOIR TRANSFÉRÉ LES FICHIERS

echo "Réparation des permissions"
chown -R  www-data:www-data /var/www
chmod -R 555 /var/www
chown -R root:www-data /etc/ssl/caddy
chmod -R 0770 /etc/ssl/caddy

echo "Démarrage de Caddy"
service caddy start
service caddy status