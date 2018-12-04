  docker create \
    --name=grafana \
    -p 3000:3000 \
grafana/grafana

echo "[Unit]
Description=grafana container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a grafana
ExecStop=/usr/bin/docker stop -t 2 grafana
[Install]
WantedBy=default.target" >/etc/systemd/system/docker-grafana.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-grafana.service
systemctl start docker-grafana.service
