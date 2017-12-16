# Configuration serveur À voir et à manger

Ce dépôt contient la configuration du serveur que j'utilise pour [mon blog personnel](https://voiretmanger.fr), ainsi qu'un [script de configuration](https://github.com/nicolinuxfr/config-server/blob/master/tools/install.sh) automatisé.

Vous pouvez utiliser ce projet comme base pour le vôtre. **Ne l'utilisez pas directement**, il est adapté à mes besoins précis ! 

## Que fait le script d'installation ?

Le script est pensé pour cette configuration :

- Ubuntu 16.04 en anglais ;
- [Caddy](https://github.com/mholt/caddy) en guise de serveur web ;
- PHP 7.1 et MariaDB 10.1 ;
- WordPress.

Son rôle est d'installer tous les programmes nécessaires et créer des liens symboliques pour tous les fichiers de configuration contenus dans ce dépôt.

## Mode d'emploi

Voici les étapes à suivre sur un serveur vide : 

### Récupérer le dépôt

Cloner le dépôt n'importe où sur le serveur : 

     git clone https://github.com/nicolinuxfr/config-server.git /home/config

### Lancer le script

Certaines opérations nécessitent les permissions root, d'où le `sudo`. 

    sudo /home/config/tools/install.sh

## Crédits

