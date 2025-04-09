# Tutorial Mowgli

## Installation de dietpi
### Configuration du fichier dietpi.txt

```
AUTO_SETUP_LOCALE=fr_FR.UTF-8 (Langue du systeme)
AUTO_SETUP_KEYBOARD_LAYOUT=fr (Layout du clavier)
AUTO_SETUP_TIMEZONE=Europe/Paris (Timezone)
AUTO_SETUP_NET_ETHERNET_ENABLED=0 (Désactiver le port ethernet: *facultatif*)
AUTO_SETUP_NET_WIFI_ENABLED=1 (Activer le port ethernet: **obligatoire**)
AUTO_SETUP_NET_WIFI_COUNTRY_CODE=FR (Code pays wifi)

AUTO_SETUP_NET_USESTATIC=1 (Forcer à utiliser une adresse IP static)
AUTO_SETUP_NET_STATIC_IP=192.168.1.80 (Adresse IP du robot)
AUTO_SETUP_NET_STATIC_MASK=255.255.255.0 (Masque de sous reseau)
AUTO_SETUP_NET_STATIC_GATEWAY=192.168.1.254 (Gateway)
AUTO_SETUP_NET_STATIC_DNS=9.9.9.9 149.112.112.112 (Serveur DNS)
AUTO_SETUP_DHCP_TO_STATIC=1 (???)
AUTO_SETUP_NET_HOSTNAME=Mowgli (Nom d'hote)

AUTO_SETUP_HEADLESS=1 (Désactiver la sorti hdmi: *facutlatif*)

AUTO_SETUP_SSH_SERVER_INDEX=-2 (Serveur SSH, mettre 2 pour installer openSSH, l'option par defaut "dropbear" ne permet pas la connection SFTP pour le transfert de fichier)

AUTO_SETUP_SSH_PUBKEY=ssh-rsa AAAABBBB***** (Clé SSH)

AUTO_SETUP_AUTOMATED=1 (Passer l'etape d'installation de DietPi)

AUTO_SETUP_GLOBAL_PASSWORD=**** (Mot de passe root)

AUTO_SETUP_INSTALL_SOFTWARE_ID=134 162 185 (Installation de docker compose, docker et portainer)

SURVEY_OPTED_IN=0 (Désactivation de l'envoi de statistiques aux serveurs DietPi)
```

### Configuration du fichier dietpi-wifi.txt

```
aWIFI_SSID[0]='*****' (SSID Wifi)
aWIFI_KEY[0]='*****' (Mot de passe Wifi)
```
