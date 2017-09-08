docker create \
    --name=ombi \
    -v /etc/localtime:/etc/localtime:ro \
   -v /local/media/ombi:/config \
    -e PGID=1010 -e PUID=1010  \
    -e TZ=<timezone> \
    -p 3600:3600 \
    linuxserver/ombi

echo "[Unit]
Description=ombi container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a ombi
ExecStop=/usr/bin/docker stop -t 2 ombi
[Install]
WantedBy=default.target" >/etc/systemd/system/docker-ombi.service


# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-ombi.service
systemctl start docker-ombi.service
