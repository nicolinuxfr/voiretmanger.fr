#!/bin/sh

# Script de mise à jour

# Caddy
curl https://getcaddy.com | bash -s personal
setcap cap_net_bind_service=+ep $(which caddy)
service caddy restart

# WP-CLI
wp cli update