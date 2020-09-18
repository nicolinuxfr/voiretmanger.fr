#!/bin/bash

# Script qui permet de mettre à jour la configuration depuis le dépôt et d'installer les fichiers au bon endroit.

CONFIG="/home/ubuntu/config"

cd $CONFIG
git pull origin

# Installation de la nouvelle version du fichier Caddyfile
cp -rf etc/caddy/Caddyfile /etc/caddy/
chown caddy:caddy /etc/caddy/Caddyfile
chmod 444 /etc/caddy/Caddyfile

# Rechargements en cas de changement
systemctl reload caddy
