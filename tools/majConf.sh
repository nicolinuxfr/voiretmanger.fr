#!/bin/sh

# Script qui permet de mettre à jour la configuration depuis le dépôt et d'installer les fichiers au bon endroit.

cd /root/config/
git pull origin master

cp -rf etc/caddy/Caddyfile /etc/caddy/
chown www-data:www-data /etc/caddy/Caddyfile
chmod 444 /etc/caddy/Caddyfile

cp -rf etc/cron.d/perso /etc/cron.d/
chmod 644 /etc/cron.d/perso