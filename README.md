# Configuration serveur À voir et à manger

Ce dépôt contient la configuration du serveur que j'utilise pour [mon blog personnel](https://voiretmanger.fr), ainsi qu'un [script de configuration](https://github.com/nicolinuxfr/config-server/blob/master/tools/install.sh) automatisé.

Vous pouvez utiliser ce projet comme base pour le vôtre. **Ne l'utilisez pas directement**, il est adapté à mes besoins précis ! 

## Que fait le script d'installation ?

Le script installe ces outils sur une base d'Ubuntu 16.04 :

- Serveur web :
    - [Caddy](https://github.com/mholt/caddy) ;
    - PHP 7.1 ;
    - MariaDB 10.1 ;
- Terminal :
    - ZSH et oh-my-zsh ;
    - htop ;
    - micro ;
    - goaccess.

Il installe aussi les fichiers de configuration stockés dans le sous-dossier `/etc/`, grâce à des liens symboliques qui simplifient ensuite les mises à jour.

## Mode d'emploi

### Prérequis

Le script d'installation est conçu pour être exécuté à partir d'un serveur sous Ubuntu 16.04 et d'un compte non root. Pour la configuration initiale de l'utilisateur, vous pouvez [suivre ce tutoriel](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04).

### Récupérer le dépôt

Vous pouvez cloner le dépôt n'importe où sur le serveur, par simplicité je le fais depuis le dossier personnel de l'utilisateur.

     git clone https://github.com/nicolinuxfr/config-server.git config

### Lancer le script

Certaines opérations nécessitent les permissions root, d'où le `sudo`. 

    sudo config/tools/install.sh

## Crédits

