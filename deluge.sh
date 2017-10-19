#!/bin/bash
#  Usage: ./build.sh
#  Description: Build docker container for Trans
#  Author: Randle Gold 
#  Version 1.0 
#  Created: March 26, 2017
#-----------------------------------#
#-----------------------------------#

# Functions


# Grab uid and gid for plex user
#USERID=`id -u plex`
#GROUPID=`id -g plex`

docker create \
  --name deluge \
  --net=host \
  -e PUID=1010 -e PGID=1010 \
  -e TZ="America/Edmonton" \
  -e UMASK_SET=22 \
  -v /MediaStore/:/downloads \
  -v /local/media/deluge:/config \
  linuxserver/deluge



# Created systemd startup scripts for containers
echo "[Unit]
Description=Deluge container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a deluge
ExecStop=/usr/bin/docker stop -t 2 deluge

[Install]
WantedBy=default.target" >/etc/systemd/system/docker-deluge.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-deluge.service
systemctl start docker-deluge.service
