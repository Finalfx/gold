#!/bin/bash
#  Usage: ./build.sh
#  Description: Build docker container for Trans
#  Author: Randle Gold 
#  Version 1.0 
#  Created: March 26, 2017
#-----------------------------------#
#-----------------------------------#

docker create \ 
  --name=plexpy \
  -v /local/media/plexpy:/config \
  -v /var/lib//plexmediaserver/Library/Application Support/Plex Media Server/Logs/:/logs:ro \
  -e PGID=1010 -e PUID=1010  \
  -e TZ="America/Edmonton" \
  -p 8181:8181 \
  linuxserver/plexpy
  
# Created systemd startup scripts for containers

echo "[Unit]
Description=Plexpy Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a Plexpy
ExecStop=/usr/bin/docker stop -t 2 Plexpy

[Install]
WantedBy=default.target" >/etc/systemd/system/docker-Plexpy.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-Plexpy.service
systemctl start docker-Plexpy.service
