

  docker create \
    --name=radarr \
    -v /local/media/radarr:/config \
    -v /MediaStore:/downloads \
    -v /MediaStore:/local/media \
    -e PGID=1010 -e PUID=1010  \
    -e TZ="America/Edmonton" \
    -p 7878:7878 \
linuxserver/radarr

echo "[Unit]
Description=radarr container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a radarr
ExecStop=/usr/bin/docker stop -t 2 radarr

[Install]
WantedBy=default.target" >/etc/systemd/system/docker-radarr.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-radarr.service
systemctl start docker-radarr.service
