#!/usr/bin/env bash

# colores
VERDE="\e[0;32m\033[1m"
ROJO="\e[0;31m\033[1m"
AMARILLO="\e[0;33m\033[1m"
FIN="\033[0m\e[0m"

# CTRL-C
trap ctrl_c INT
function ctrl_c(){
        echo -e "\n${ROJO}Programa Terminado ${FIN}"
        exit 0
}

echo -e "${AMARILLO}[GRAFANA] Descargando las llaves ${FIN}"
wget -qO- https://packages.grafana.com/gpg.key | sudo apt-key add -

echo -e "${AMARILLO}[GRAFANA] Agregando el repositorio ${FIN}"
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

echo -e "${AMARILLO}[GRAFANA] Instalando grafana ${FIN}"
sudo apt update && sudo apt install -y grafana

echo -e "${AMARILLO}[GRAFANA] Activando + Iniciando el servicio ${FIN}"
sudo systemctl daemon-reload && sudo systemctl enable grafana-server --now

