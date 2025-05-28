# Tutorial Mowgli

Dans ce tuto, je vais me concentrer sur l'utilisation de DietPi pour le projet Mowgli, permettant de faire fonctionner un robot tondeuse YardForce sans fil périphérique grâce à un GPS et un accéléromètre/compas, sur un Raspberry Pi.

Je ne vais pas détailler le branchement à l'intérieur du robot, et pour cela, je vous recommande les tutos suivants :  
- [Tuto d’ArminasTV](https://domoplus.eu/2023/10/15/openmower-construire-un-robot-tondeuse-intelligent-et-precis-avec-un-gps-rtk/)  
- [Tuto de Juditech3D](https://github.com/juditech3D/Guide-DIY-OpenMower-Mowgli-pour-Robots-Tondeuses-Yard500-et-500B/tree/main)  
- [Tuto en anglais avec un OrangePi à la place du Raspberry Pi](https://ne.greitai.eu/posts/yardforce-sa900eco-with-openmower/)

Je vous invite également à suivre les communautés travaillant sur ce projet, qui sont d'une aide précieuse :  
- [Groupe Telegram en français](https://t.me/+x6U3UwU5lB4yOWNk)  
- [Groupe Discord en anglais](https://discord.gg/jE7QNaSxW7)

## Installation de dietpi

Téléchargez l’image DietPi correspondant à votre Raspberry Pi sur [https://dietpi.com/#downloadinfo](https://dietpi.com/docs/install/) et suivez les étapes d'installation décrites sur leur site.

Une fois l’image installée sur la carte SD, il est possible de tout configurer directement en modifiant le fichier `dietpi.txt`, ce qui peut éviter d’avoir à brancher un écran sur le Raspberry Pi pour le premier démarrage (même si c’est recommandé, au cas où une erreur surviendrait).

### Configuration du fichier dietpi.txt
Dans le fichier `dietpi.txt`, voici les paramètres que je vous conseille de modifier :
```
AUTO_SETUP_LOCALE=fr_FR.UTF-8 (Langue du systeme)
AUTO_SETUP_KEYBOARD_LAYOUT=fr (Layout du clavier)
AUTO_SETUP_TIMEZONE=Europe/Paris (Timezone)
AUTO_SETUP_NET_ETHERNET_ENABLED=0 (Désactiver le port ethernet: *facultatif*)
AUTO_SETUP_NET_WIFI_ENABLED=1 (Activer le port ethernet: **obligatoire**)
AUTO_SETUP_NET_WIFI_COUNTRY_CODE=FR (Code pays wifi)

AUTO_SETUP_NET_USESTATIC=1 (Forcer à utiliser une adresse IP static)
AUTO_SETUP_NET_STATIC_IP=192.168.***.*** (Adresse IP du robot, bien sur remplacez les *** par ce que vous désirez sur votre reseau)
AUTO_SETUP_NET_STATIC_MASK=255.255.255.0 (Masque de sous reseau)
AUTO_SETUP_NET_STATIC_GATEWAY=192.168.***.*** (Gateway, bien sur remplacez les *** par l'adresse de votre box internet ou router)
AUTO_SETUP_NET_STATIC_DNS=9.9.9.9 149.112.112.112 (Serveur DNS)
AUTO_SETUP_NET_HOSTNAME=Mowgli (Nom d'hote)

AUTO_SETUP_HEADLESS=1 (Désactiver la sorti hdmi: *facultatif etpas forcément recommandé*)

AUTO_SETUP_SSH_SERVER_INDEX=-2 (Serveur SSH, mettre 2 pour installer openSSH, l'option par defaut "dropbear" ne permet pas la connection SCP pour le transfert de fichier)

AUTO_SETUP_SSH_PUBKEY=ssh-rsa AAAABBBB***** (Clé SSH)

AUTO_SETUP_AUTOMATED=1 (Lancer l'etape d'installation de DietPi automatiquement lors du 1er démarrage)

AUTO_SETUP_GLOBAL_PASSWORD=**** (Mot de passe root)

AUTO_SETUP_INSTALL_SOFTWARE_ID=17 134 162 (Installation de git, docker compose, docker)

SURVEY_OPTED_IN=0 (Désactivation de l'envoi de statistiques aux serveurs DietPi)
```

### Configuration du fichier dietpi-wifi.txt
Veuillez également modifier le fichier `dietpi-wifi.txt` pour connecter votre Raspberry Pi à votre réseau local.
```
aWIFI_SSID[0]='*****' (SSID Wifi)
aWIFI_KEY[0]='*****' (Mot de passe Wifi)
```

## Installation de mowgli-docker
Une fois l'installation terminée, connectez-vous à votre Raspberry Pi et exécutez les commandes suivantes :
```
git clone https://github.com/cedbossneo/mowgli-docker.git
cd mowgli-docker
nano docker-compose.yaml
```
*Optionnel :* Commentez toutes les lignes contenant `ROSCONSOLE_CONFIG_FILE` et `ROSOUT_DISABLE_FILE_LOGGING` (cela permet d’avoir plus de logs d’erreurs).

## Configuration de udev
(j'ai repris le tuto de Juditech3D pour cette partie)

1. Créez et éditez le fichier de règles udev :
```sh
sudo nano /etc/udev/rules.d/50-mowgli.rules
```

2. Ajoutez les règles suivantes :
```sh
SUBSYSTEM=="tty" ATTRS{product}=="Mowgli", SYMLINK+="mowgli"
# simpleRTK USB
SUBSYSTEM=="tty" ATTRS{idVendor}=="1546" ATTRS{idProduct}=="01a9", SYMLINK+="gps"
# ESP USB CDC - RTK1010Board
SUBSYSTEM=="tty" ATTRS{idVendor}=="303a" ATTRS{idProduct}=="4001", SYMLINK+="gps"
# UM982 - WittMotion WTRTK-982
SUBSYSTEM=="tty" ATTRS{idVendor}=="1a86" ATTRS{idProduct}=="7523", SYMLINK+="gps"
```

(si GPS spécifique, utilisez la commande `lsusb` une fois votre appareil connecté afin de trouver les vendorId et productID)

Faites Ctrl "o" pour enregistrer et valider avec la touche "Entrée", puis Ctrl "x" pour sortir.

3. Rechargez les règles udev :
```sh
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## Configuration de l'environnement

1. Créez et éditez le fichier `.env` (il faut etre dans le répertoire mowgli-docker, si vous n'y etes pas faites "cd mowgli-docker") :
```sh
sudo nano .env
```

2. Remplacez les valeurs `ROS_IP` et `MOWER_IP` par l'adresses IP de votre raspberry (pour info le pavé numerique ne fonctionne pas , déplacer le curseur avec les fleche de navigation) :
```sh
# ROS_IP est l'IP de la machine exécutant le conteneur Docker
# MOWER_IP est l'IP de la tondeuse
# Lorsque vous n'êtes pas en mode ser2net, les deux IPs doivent être les mêmes
ROS_IP=192.168.X.XX
MOWER_IP=192.168.X.XX
IMAGE=ghcr.io/cedbossneo/mowgli-docker:cedbossneo
```

Faites Ctrl "o" pour enregistrer et valider avec la touche "Entrée", puis Ctrl "x" pour sortir.

## Démarrage de docker

```
docker compose up -d
```

## Installation du firmware

### Sur votre PC
Pour cette partie il faut retourner sur votre PC, afin de compiler le firmware grace à vscode.
Clonez le projet [https://github.com/Nekraus/Mowgli.git](https://github.com/Nekraus/Mowgli.git) sur votre ordinateur et installez l’extension PlatformIO IDE sur VSCode.

Une fois le projet cloné, ouvrez le répertoire `stm32/ros_usbnode` avec VSCode et modifiez le fichier `include/board.h`.

Si vous avez un YardForce SA... modifiez la ligne :
```
#define PANEL_TYPE PANEL_TYPE_YARDFORCE_500_CLASSIC
```
par
```
#define PANEL_TYPE PANEL_TYPE_YARDFORCE_900_ECO
```
Le reste peut rester par defaut, à moins de savoir ce que vous faites.

Dans la barre en bas de VSCode, choisissez la bonne plateforme:
- YardForce500 si vous avez une carte mere avec une puce STM32F01
- YardForce500B si vous avez une puce STM32F04
![VSCODE choix de la plateforme](https://github.com/user-attachments/assets/b8c47e39-e898-4dea-9db6-7f57836cb3e6)

Ensuite, cliquez sur le bouton en forme de V pour lancer le build.
![VSCODE build](https://github.com/user-attachments/assets/379ede34-d77b-4ad9-9213-2db8afe81b65)

Il faut maintenant envoyé le firmware générer sur le raspberry pi mowgli. Pour cela vous pouvez installer WinSCP si vous etes sous windows ou le faire en ligne de commande comme indiqué:
```
scp .pio/build/Yardforce500/firmware.bin root@192.168.***.***:/root/firmware.bin
```

### Sur le raspberry pi Mowgli
Reconnectez-vous au raspbery pi et créez un fichier yardforce500.cfg (peu importe l'emplacement du fichier) et insérer le contenu suivant:
```
source [find interface/stlink-v2.cfg]
source [find target/stm32f1x.cfg]

transport select hla_swd
```

Installer openocd sur le raspberry pi
```
apt install openocd -y
```

Puis lancer la commande suivante pour envoyer le firmware sur la carte mere du robot
```
openocd -f yardforce500.cfg  -c " program "firmware.bin" 0x08000000 verify reset; shutdown;"
```

## Utilisation en 4G

Ayant un grand jardin je ne pouvais pas couvrir l'intégralité de mon jardin en wifi comme c'est recommande sur ce genre de projet. J'ai donc ajouté un clé usb 4G Huawei E3372h-320 [https://www.amazon.fr/dp/B085RDTZMP](https://www.amazon.fr/dp/B085RDTZMP) à l'interieur de mon robot, branché sur le seul port usb encore libre sur mon raspberry pi.

Une fois branché cette carte est par défaut en mode stockage, car elle contient un petit disque contenant les drivers windows. Il faut donc la mettre en mode reseau 4G, qui est automatiquement reconnu par linux.

Pour cela il faut installer usb-modeswitch grace à la commande suivante:
```
apt install usb-modeswitch -y
```

Puis de créer un fichier /etc/usb_modeswitch.conf ayant le contenu suivant
```
 # Huawei E353 (3.se) and others
 TargetVendor=0x12d1
 TargetProductList="14db,14dc"
 HuaweiNewMode=1
 NoDriverLoading=1
```

Enfin lancez la commande suivante pour passer en mode reseau:
```
usb_modeswitch -v 12d1 -p 1f01 -c /etc/usb_modeswitch.conf
```
Si vous utilisez une autre clé 4G que celle indiqué vous pouvez obtenir les identifiants -v et -p de la commande précédente en utilisant la commande
```
lsusb
```
et en identifiant la ligne de votre clé 4G qui apparait en (Mass storage mode)

### Sur freebox

Les fournisseur 4G (du moins en france) ne permettent pas d'obtenir une IP fixe et d'utiliser une carte 4G en mode serveur. Il faut donc créer un réseau virtuel VPN sur votre connection maison (firbe ou ADSL), sur lequel le raspberry pi de votre robot vas se connecter et être identifié comme un élément du reseau local alors qu'il est connecté en 4G.

Pour cela j'ai utilisé ma freebox qui comprend par défaut un serveur VPN. Sur les autres box il peut être nécessaie d'installer un serveur VPN sur un serveur distant ou un autre raspberry pi connecté au reseau local. Je ne vais pas rentrer dans les détails de l'installation dans ce cas, car je n'ai pas testé, mais libre à vous de modifier ce tuto (et de m'envoyer un pull request) pour y ajouter les informations pour d'autres méthodes d'installation.

Dans votre navigateur connectez vous à l'interface d'administration de votre freebox à l'url [https://mafreebox.freebox.fr/](https://mafreebox.freebox.fr/)

Puis cliquer sur le bouton Paramètres de la freebox.
![FREEBOX bouton parametres](https://github.com/user-attachments/assets/8bb9fe72-f848-4fcc-abcb-034125243e7c)

Ensuite séléctionner l'onglet Mode avancé puis cliquer sur l'icone Serveur VPN
![FREEBOX page parametres](https://github.com/user-attachments/assets/329ad02b-d0f7-480c-b80f-529ed5e56d8a)

Dans les onglets à droite séléctionner Utilisateurs et créer un utilisateur (mowgli par exemple)
![FREEBOX serveur VPN nouvel utilisateur](https://github.com/user-attachments/assets/6c32bb93-9ea7-4d36-bc93-b657b901ab61)

Puis dans l'onglet wireguard cliquer sur "Activer" et télécharger le fichier de configuration sur la ligne de votre utilisateur
![FREEBOX serveur VPN Wireguard](https://github.com/user-attachments/assets/e0db40a3-b4ef-4f67-a301-0f1f6b4d1b28)

Retournez dans les parametres de la Freebox et cliquez sur l'icone gestion des ports.
Puis ajouter une redirection pour chacun des ports suivant
- 22 pour se connecter en SSH sur votre raspberry pi
- 4005 pour accéder à l'interface Openmower GUI
- 4006 pour accéder à l'interface Openmower App
- 9001 et 9002 pour les connections websockets à l'interieur de l'interface Openmower App
![FREEBOX nouveau port](https://github.com/user-attachments/assets/dda53b2a-93d1-49aa-9b2b-85612cb6c21a)

![FREEBOX ports](https://github.com/user-attachments/assets/5bec39eb-b03c-4381-8e34-c61114c9a092)

### Sur le raspberry pi Mowgli

Copier le fichier de conf wireguard dans /etc/wireguard

Modifier le fichier .env contenu dans le répertoire mowgli-docker afin d'y affecter l'adresse ip local de votre dongle 4G. Pour obtenir cette IP vous pouvez lancer la commande
```
ifconfig
```
et localisez la ligne ETH1 qui a été créé par la clé usb 4G.

A l'interieur du répertoire mowgli-docker executer les commandes suivantes pour redémarrer openmower
```
docker compose stop
docker compose up -d
```

Vous pouvez maintenant vous connecter à l'interface openmower en utilisant l'adresse IP de votre Freebox (visible dans "Etat de la freebox" -> "Etat Internet", ligne Adresse IPv4) suivi du port 4005 ou 4006 pour afficher les 2 applis openmower.

Exemple: http://88.170.135.***:4005
