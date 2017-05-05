

  docker create \
    --name=jackett \
    -v /local/media/jackett:/config \
    -v /MediaStore:/downloads \
    -e PGID=1010 -e PUID=1010  \
    -e TZ="America/Edmonton" \
    -p 9117:9117 \
linuxserver/jackett

echo "[Unit]
Description=jackett container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a jackett
ExecStop=/usr/bin/docker stop -t 2 jackett
[Install]
WantedBy=default.target" >/etc/systemd/system/docker-jackett.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-jackett.service
