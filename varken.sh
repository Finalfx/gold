#Requires /local/media/varken exists and varken.ini exists

docker create \
  --name=varken \
  -v /local/media/varken:/config \
  -e PGID=1010 -e PUID=1010  \
  -e TZ="America/Edmonton" \
  boerderij/varken
  
  echo "[Unit]
Description=varken container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a varken
ExecStop=/usr/bin/docker stop -t 2 varken
[Install]
WantedBy=default.target" >/etc/systemd/system/docker-varken.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-varken.service
systemctl start docker-varken.service
