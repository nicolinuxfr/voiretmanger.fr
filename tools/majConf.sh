#!/bin/sh

# Script qui permet de mettre à jour la configuration depuis le dépôt et d'installer les fichiers au bon endroit.

cd ~/config/
git pull origin

cp -rf etc/caddy/Caddyfile /etc/caddy/
chown caddy:caddy /etc/caddy/Caddyfile
chmod 444 /etc/caddy/Caddyfile

