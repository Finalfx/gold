 #!/bin/bash
#  Usage: ./nzbget.sh
#  Description: Build docker containers for home plex environment
#  Author: Randle Gold
#  Version 1.0 
#  Created: April 12, 2018
#-----------------------------------#
#-----------------------------------#
 
 
 
 docker create \
    --name nzbget \
    -p 6789:6789 \
    -e PUID=$USERID -e PGID=$GROUPID \
    -e TZ="America/Edmonton" \
    -v /local/MediaStore:/local/media \
    -v /local/media/nzbget:/config \
    -v /MediaStore/NzbGetDownloads:/downloads \
linuxserver/nzbget

# Created systemd startup scripts for containers
echo "[Unit]
Description=nzbget container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a nzbget
ExecStop=/usr/bin/docker stop -t 2 nzbget
[Install]
WantedBy=default.target" >/etc/systemd/system/docker-nzbget.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-nzbget.service

systemctl start docker-nzbget.service
