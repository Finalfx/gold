
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
USERID=`id -u plex`
GROUPID=`id -g plex`

  docker create --name=transmission \
    -v /local/media/transmission:/config \
    -v /MediaStore/complete:/downloads \
    -v /MediaStore/torrents:/watch \
    -e PGID=1010 -e PUID=1010  \
    -e TZ="America/Edmonton" \
    -p 9091:9091 -p 50001:50001 \
    -p 50001:50001/udp \
    linuxserver/transmission


# Created systemd startup scripts for containers
echo "[Unit]
Description=Transmission container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a transmission
ExecStop=/usr/bin/docker stop -t 2 transmission

[Install]
WantedBy=default.target" >/etc/systemd/system/docker-transmission.service

# Enable containers at system startup 
#systemctl daemon-reload
#systemctl enable docker-transmission.service
#systemctl start docker-transmission.service
