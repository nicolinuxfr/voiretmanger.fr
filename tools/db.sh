#!/bin/sh
# Script d'optimisation et de sauvegarde de la base de données. Repose sur WP-CLI. 

DATE=`date +%Y-%m-%d`

echo "Optimisation et sauvegarde de la base de données : $DATE"

# Optimisations (basé sur https://gist.github.com/lukecav/66f1039edcd2827fd1bde82dce86a2be)
wp transient delete --expired 
wp cache flush
wp post delete $(wp post list --post_type='revision' --format=ids)
wp db optimize

# Sauvegarde
wp db export /home/backup/$DATE.sql

# Nettoyage des anciennes sauvegardes (5 derniers jours)
find /home/backup/ -maxdepth 1 -type f -mmin +7200 | xargs rm -rf