#!/bin/sh
# Script d'optimisation et de sauvegarde de la base de données. Repose sur WP-CLI. 

DATE=`date +%Y-%m-%d`

echo "Optimisation et sauvegarde de la base de données : $DATE"

# Optimisations (basé sur https://gist.github.com/lukecav/66f1039edcd2827fd1bde82dce86a2be)
/usr/local/bin/wp transient delete --expired 
/usr/local/bin/wp cache flush
/usr/local/bin/wp post delete $(/usr/local/bin/wp post list --post_type='revision' --format=ids)
/usr/local/bin/wp db optimize

# Sauvegarde
/usr/local/bin/wp db export ~/backup/$DATE.sql

# Nettoyage des anciennes sauvegardes (5 derniers jours)
find ~/backup/ -maxdepth 1 -type f -mmin +7200 | xargs rm -rf