#!/bin/sh
# Script d'optimisation et de sauvegarde de la base de données. Repose sur WP-CLI. 

DATE=`date +%Y-%m-%d`
FOLDER='/home/ubuntu/backup'

echo "Optimisation et sauvegarde de la base de données : $DATE"

cd /var/www/voiretmanger.fr/

# Optimisations (basé sur https://gist.github.com/lukecav/66f1039edcd2827fd1bde82dce86a2be)
/usr/local/bin/wp --allow-root transient delete --expired 
/usr/local/bin/wp --allow-root cache flush
/usr/local/bin/wp --allow-root post delete --force $(/usr/local/bin/wp --allow-root post list --post_type='revision' --format=ids)
/usr/local/bin/wp --allow-root db optimize

# Sauvegarde
/usr/local/bin/wp --allow-root db export - | gzip > $FOLDER/$DATE.sql.gz

# Backup Teslamate
echo "Sauvegarde de la base de données Teslamate"

cd /home/ubuntu/teslamate
/usr/bin/docker-compose exec -T database pg_dump -U nicoflo teslamate | gzip > $FOLDER/teslamate_$DATE.bck.gz

# Permissions
chown -R ubuntu:ubuntu $FOLDER

# Nettoyage des anciennes sauvegardes (5 derniers jours)
find $FOLDER -maxdepth 1 -type f -mmin +7200 | xargs rm -rf