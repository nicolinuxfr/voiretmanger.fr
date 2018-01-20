# Configuration serveur À voir et à manger

Ce dépôt contient la configuration du serveur que j'utilise pour [mon blog personnel](https://voiretmanger.fr), ainsi qu'un [script de configuration](https://github.com/nicolinuxfr/config-server/blob/master/tools/install.sh) automatisé.

Vous pouvez utiliser ce projet comme base pour le vôtre. **Ne l'utilisez pas directement**, il est adapté à mes besoins précis ! 

## Que fait le script d'installation ?

Le script installe ces outils sur une base d'Ubuntu 16.04 :

- Serveur web :
    - [Caddy](https://github.com/mholt/caddy) ;
    - PHP 7.2 ;
    - MariaDB 10.2 ;
- Terminal :
    - ZSH et oh-my-zsh ;
    - htop ;
    - micro ;
    - goaccess.

Il installe aussi les fichiers de configuration stockés dans le sous-dossier `/etc/`, grâce à des liens symboliques qui simplifient ensuite les mises à jour.

Il crée enfin les dossiers nécessaires pour héberger les sites et les logs : 

- Données : dans `/var/www/ndd.fr` ;
- Logs : dans `/var/log/caddy/`.

## Mode d'emploi

### Configuration initiale du serveur

Le script d'installation est conçu pour être exécuté à partir d'un serveur sous Ubuntu 16.04 et d'un compte non root. Pour la configuration initiale de l'utilisateur, vous pouvez [suivre ce tutoriel](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04).

Voici les commandes que je saisis sur mes VPS : 

- Connexion en root : `ssh root@IP.IP.IP.IP` ;
- Ajout utilisateur : `adduser nicolas` ;
- Droit root : `usermod -aG sudo nicolas` ;
- Envoi du mot de passe utilisateur depuis l'ordinateur local : `ssh-copy-id nicolas@IP.IP.IP.IP` ;
- Connexion avec l'utilisateur : `ssh nicolas@IP.IP.IP.IP` ;
- Vérifications : fermer la session et la rouvrir pour voir si tout est correct.


### Récupérer le dépôt

Clonez le dépôt à partir du dossier utilisateur qui servira à exécuter le script. Les configurations seront aussi stockées dans ce dossier et liées vers ce dossier, donc il ne faudra plus y toucher.

    git clone https://github.com/nicolinuxfr/config-server.git ~/config

### Lancer le script

Certaines opérations nécessitent les permissions root, d'où le `sudo`. 

    sudo ~/config/tools/install.sh

⚠️ **ATTENTION** ⚠️

Ne relancez pas le script une deuxième fois sur un serveur !

### Après le script

Le script indique à la fin la commande à exécuter depuis un ordinateur local, ou bien sur le serveur précédent, pour initier le transfert des données. Par simplicité, le transfert est effectué en root.

Par sécurité, il est conseillé de désactiver la possibilité d'utiliser root ensuite : 

- Édition configuration : `sudo nano /etc/ssh/sshd_config` ; 
- Modification de la ligne `PermitRootLogin yes` > `PermitRootLogin no` ;
- Redémarrage serveur SSH : `sudo systemctl reload sshd`.

Seul l'utilisateur créé précédemment aura alors accès au serveur en SSH. Pensez à vérifier que c'est bien le cas en ouvrant une nouvelle session, avant de fermer la session en cours. 

Après cela, importer les données MySQL et lancer Caddy. Pour le HTTPS, le nom de domaine doit déjà pointer sur le serveur.