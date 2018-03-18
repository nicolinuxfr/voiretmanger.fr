#!/bin/sh

# Ce script doit être exécuté après le script "install.sh" ET APRÈS AVOIR TRANSFÉRÉ LES FICHIERS

echo "Réparation des permissions"
chown -R  www-data:www-data /var/www
chmod -R 555 /var/www
chmod -R 755 /var/www/voiretmanger.fr/wp-content/
chown -R root:www-data /etc/ssl/caddy
chmod -R 0770 /etc/ssl/caddy

echo "Démarrage de Caddy"
systemctl daemon-reload
service caddy start
service caddy status