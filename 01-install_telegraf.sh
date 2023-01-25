#!/usr/bin/env bash

#Colours
VERDE="\e[0;32m\033[1m"
ROJO="\e[0;31m\033[1m"
AMARILLO="\e[0;33m\033[1m"
FIN="\033[0m\e[0m"

#CTRL-C
trap ctrl_c INT
function ctrl_c(){
        echo -e "\n${ROJO}Programa Terminado ${FIN}"
        exit 0
}

echo -e "\n${AMARILLO}[TELEGRAF] Descargando llave ${FIN}"
wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -

echo -e "\n${AMARILLO}[TELEGRAF] Agregando repositorio ${FIN}"
source /etc/lsb-release && echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list >/dev/null

echo -e "\n${AMARILLO}[TELEGRAF] Instalando telegraf ${FIN}"
sudo apt update && sudo apt install -y telegraf 2>/dev/null

echo -e "\n${AMARILLO}[TELEGRAF] Backupeando la config ${FIN}"
sudo cp /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.bk

echo -e "\n${AMARILLO}[TELEGRAF] Configurando telegraf ${FIN}"

sudo tee /etc/telegraf/telegraf.conf >/dev/null <<EOF
# Input plugins
# Ping plugin
[[inputs.ping]]
  urls = ["kite.zerodha.com", "google.com", "reddit.com", "twitter.com", "amazon.in", "zerodha.com"]
  count = 4
  ping_interval = 1.0
  timeout = 2.0

# DNS plugin
[[inputs.dns_query]]
  servers = ["8.8.8.8"]
  domains = ["kite.zerodha.com", "google.com", "reddit.com", "twitter.com", "amazon.in", "zerodha.com"]

# Output format plugins
[[outputs.prometheus_client]]
  listen = ":9283"
  metric_version = 2
EOF

echo -e "\n${AMARILLO}[TELEGRAF] Recargando + Reiniciando el servicio ${FIN}"
sudo systemctl daemon-reload && sudo systemctl restart telegraf.service

echo -e "\n${AMARILLO}[TELEGRAF] Chequeando el estado del servicio ${FIN}"
sleep 6 && curl -s localhost:9283/metrics | head

