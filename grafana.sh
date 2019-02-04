  docker create \
    --name=grafana \
    --user 1010
    --volume "/local/media/grafana:/var/lib/grafana"
    --volume "/local/media/grafana/conf:/etc/grafana"
    -p 3000:3000 \
    -e "GF_SECURITY_ADMIN_PASSWORD=#report"
    -e "GF_INSTALL_PLUGINS=natel-influx-admin-panel,ryantxu-annolist-panel,jdbranham-diagram-panel,grafana-worldmap-panel,grafana-piechart-panel"
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
