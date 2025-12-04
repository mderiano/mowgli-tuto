#!/bin/bash

# Configuration
WIFI_IF="wlan0"
LTE_IF="eth1"
WIFI_GW="192.168.1.254"
LTE_GW="192.168.8.1"
CHECK_IP="8.8.8.8"
CHECK_INTERVAL=5
FAIL_THRESHOLD=2

# Variables d'état
wifi_fails=0
current_primary="unknown"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a /var/log/network-failover.log
}

wifi_is_up() {
    ip link show $WIFI_IF 2>/dev/null | grep -q "state UP"
}

wifi_has_ip() {
    ip addr show $WIFI_IF 2>/dev/null | grep -q "inet "
}

wifi_can_ping() {
    ping -I $WIFI_IF -c 1 -W 2 $CHECK_IP > /dev/null 2>&1
}

set_wifi_primary() {
    if [ "$current_primary" != "wifi" ]; then
        log "Basculement vers WiFi"
        # Supprime l'ancienne route par défaut
        ip route del default via $LTE_GW dev $LTE_IF 2>/dev/null
        # Ajoute WiFi comme route par défaut avec métrique basse
        ip route replace default via $WIFI_GW dev $WIFI_IF metric 100
        # Garde 4G en backup
        ip route replace default via $LTE_GW dev $LTE_IF metric 600
        current_primary="wifi"
    fi
}

set_lte_primary() {
    if [ "$current_primary" != "lte" ]; then
        log "Basculement vers 4G (failover)"
        # 4G devient prioritaire
        ip route replace default via $LTE_GW dev $LTE_IF metric 100
        # WiFi en backup (si disponible)
        ip route replace default via $WIFI_GW dev $WIFI_IF metric 600 2>/dev/null
        current_primary="lte"
    fi
}

# Détection initiale
if wifi_is_up && wifi_has_ip && wifi_can_ping; then
    set_wifi_primary
else
    set_lte_primary
fi

log "Démarrage du monitoring (primaire: $current_primary)"

# Boucle principale
while true; do
    if wifi_is_up && wifi_has_ip; then
        if wifi_can_ping; then
            wifi_fails=0
            set_wifi_primary
        else
            wifi_fails=$((wifi_fails + 1))
            log "WiFi: échec ping ($wifi_fails/$FAIL_THRESHOLD)"
            if [ $wifi_fails -ge $FAIL_THRESHOLD ]; then
                set_lte_primary
            fi
        fi
    else
        wifi_fails=$FAIL_THRESHOLD
        set_lte_primary
    fi
    
    sleep $CHECK_INTERVAL
done
