docker create \
    --name sonarr \
    -p 8989:8989 \
    -e PUID=1010 -e PGID=1010 \
    -v /dev/rtc:/dev/rtc:ro \
    -v /local/media/sonarr:/config \
    -v /MediaStore:/local/media \
    -v /MediaStore/complete:/downloads \
    linuxserver/sonarr

echo "[Unit]
Description=sonarr container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a sonarr
ExecStop=/usr/bin/docker stop -t 2 sonarr

[Install]
WantedBy=default.target" >/etc/systemd/system/docker-sonarr.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-sonarr.service
systemctl start docker-sonarr.service

