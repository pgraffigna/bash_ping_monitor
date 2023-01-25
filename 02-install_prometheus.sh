#!/usr/bin/env bash

# Colores
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

echo -e "${AMARILLO}[PROMETHEUS] Creando grupo para prometheus ${FIN}"
sudo groupadd --system prometheus

echo -e "${AMARILLO}[PROMETHEUS] Creando usuario prometheus ${FIN}"
sudo useradd -s /sbin/nologin --system -g prometheus prometheus

echo -e "${AMARILLO}[PROMETHEUS] Creando carpetas necesarias ${FIN}"
sudo mkdir /var/lib/prometheus && sudo mkdir -p /etc/prometheus/{rules,rules.d,files_sd}

echo -e "${AMARILLO}[PROMETHEUS] Descargando binarios ${FIN}"
cd /tmp && curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -

echo -e "${AMARILLO}[PROMETHEUS] Extrayendo + moviendo los binarios ${FIN}"
tar xvf prometheus* &>/dev/null && sudo mv prometheus-2.41.0.linux-amd64/{prometheus,promtool} /usr/local/bin/

echo -e "${AMARILLO}[PROMETHEUS] Copiando archivos de configuracion ${FIN}"
sudo mv prometheus-2.41.0.linux-amd64/{prometheus.yml,consoles,console_libraries} /etc/prometheus

echo -e "${AMARILLO}[PROMETHEUS] Configurando el servicio ${FIN}"

sudo tee /etc/systemd/system/prometheus.service >/dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo -e "${AMARILLO}[PROMETHEUS] Configurando los permisos para las carpetas ${FIN}"
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus

echo -e "${AMARILLO}[PROMETHEUS] Configurando prometheus ${FIN}"
sudo tee /etc/prometheus/prometheus.yml >/dev/null <<EOF

global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "ping-monitor"
    scrape_interval: 60s
    static_configs:
      - targets: ["localhost:9283"]
EOF

echo -e "${AMARILLO}[PROMETHEUS] Recargando + reiniciando el servicio ${FIN}"
sudo systemctl daemon-reload && sudo systemctl enable prometheus --now