 docker create \
    --name=plexrequests \
    -v /etc/localtime:/etc/localtime:ro \
    -v /local/media/plexrequests:/config \
    -e PGID=1010 -e PUID=1010  \
    -p 3000:3000 \
linuxserver/plexrequests

echo "[Unit]
Description=plexrequests container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a plexrequests
ExecStop=/usr/bin/docker stop -t 2 plexrequests


[Install]
WantedBy=default.target" >/etc/systemd/system/docker-plexrequests.service


# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-plexrequests.service
systemctl start docker-plexrequests.service
