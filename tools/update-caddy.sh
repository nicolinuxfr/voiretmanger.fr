#!/bin/sh

# Script de mise à jour

# Caddy
## Vérifier version ici : https://github.com/caddyserver/caddy/releases
VERSION="2.0.0-rc.2"
cd /tmp/
curl --retry 5 -LO https://github.com/caddyserver/caddy/releases/download/v$VERSION/caddy_${VERSION}_Linux_x86_64.tar.gz
tar -xzf caddy_*
mv caddy /usr/local/bin/caddy

chown caddy:caddy /usr/local/bin/caddy
chmod 755 /usr/local/bin/caddy

# Correction autorisations pour utiliser les ports 80 et 443
setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

service caddy restart