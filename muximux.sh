docker create \
  --name=muximux \
  -v /local/media/muximux:/config \
  -e PGID=1010 -e PUID=1010  \
  -e TZ="America/Edmonton" -p 80:50005 \
  linuxserver/muximux
  
  echo "[Unit]
Description=muximux contrainer
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a muximux
ExecStop=/usr/bin/docker stop -t 2 muximux

[Install]
WantedBy=default.target" >/etc/systemd/system/docker-muximux.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-muximux.service
systemctl start docker-muximux.service
