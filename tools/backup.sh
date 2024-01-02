#!/bin/sh
# Script d'optimisation et de sauvegarde de la base de données. Repose sur WP-CLI. 

DATE=`date +%Y-%m-%d`
FOLDER='/home/debian/backup'

echo "Optimisation et sauvegarde de la base de données : $DATE"

cd /var/www/voiretmanger.fr/

# Optimisations (basé sur https://gist.github.com/lukecav/66f1039edcd2827fd1bde82dce86a2be)
/usr/local/bin/wp --allow-root transient delete --expired 
/usr/local/bin/wp --allow-root cache flush
/usr/local/bin/wp --allow-root post delete --force $(/usr/local/bin/wp --allow-root post list --post_type='revision' --format=ids)
/usr/local/bin/wp --allow-root db optimize

# Sauvegarde
/usr/local/bin/wp --allow-root db export - | gzip > $FOLDER/voiretmanger-$DATE.sql.gz

# Backup Teslamate
echo "Sauvegarde de la base de données Teslamate"

cd /opt/teslamate
/usr/bin/docker compose exec -T database pg_dump -U nicoflo teslamate | gzip > $FOLDER/teslamate_$DATE.bck.gz

# Backup UniFi
echo "Récupération de la sauvegarde Unifi Network"
rsync -avz /var/lib/unifi/backup/autobackup/ $FOLDER/unifi/

# Permissions
chown -R debian:debian $FOLDER

# Nettoyage des anciennes sauvegardes (5 derniers jours)
find $FOLDER -maxdepth 2 -type f -mmin +7200 | xargs rm -rf