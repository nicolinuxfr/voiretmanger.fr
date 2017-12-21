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

Voici les commandes que je saisis sur mes VPS : 

- Connexion en root : `ssh root@IP.IP.IP.IP` ;
- Ajout utilisateur : `adduser nicolas` ;
- Droit root : `usermod -aG sudo nicolas` ;
- Envoi du mot de passe utilisateur depuis l'ordinateur local : `ssh-copy-id nicolas@IP.IP.IP.IP` ;
- Connexion avec l'utilisateur : `ssh nicolas@IP.IP.IP.IP` ;
- Blocage connexion root : 
    - édition configuration : `sudo nano /etc/ssh/sshd_config` 
    - modification de la ligne `PermitRootLogin yes` > `PermitRootLogin no` ;
    - redémarrage serveur SSH : `sudo systemctl reload sshd` ;
- Vérifications : fermer la session et la rouvrir pour voir si tout est correct.


### Récupérer le dépôt

Clonez le dépôt à partir du dossier utilisateur qui servira à exécuter le script. Les configurations seront aussi stockées dans ce dossier et liées vers ce dossier, donc il ne faudra plus y toucher.

    git clone https://github.com/nicolinuxfr/config-server.git ~/config

### Lancer le script

Certaines opérations nécessitent les permissions root, d'où le `sudo`. 

    sudo ~/config/tools/install.sh

⚠️ **ATTENTION** ⚠️

Ne relancez pas le script une deuxième fois sur un serveur !
