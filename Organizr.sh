docker create \
  --name=organizr \
  -v /local/media/organizr:/config \
  -e PGID=1010 -e PUID=1010  \
  -p 50004:80 \
  lsiocommunity/organizr
  
  echo "[Unit]
Description=organizr contrainer
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a organizr
ExecStop=/usr/bin/docker stop -t 2 organizr

[Install]
WantedBy=default.target" >/etc/systemd/system/docker-organizr.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-organizr.service
systemctl start docker-organizr.service
