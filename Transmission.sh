
#!/bin/bash
#  Usage: ./build.sh
#  Description: Build docker containers for home plex environment
#  Author: Dustin Lactin 
#  Version 1.0 
#  Created: December 14th, 2016
#-----------------------------------#
#-----------------------------------#

`docker inspect Transmission | grep -E 'running' >/dev/null`
if [[ $? -eq 1 ]]; then
  docker create \
    --name=transmission \
    -v /local/media/transmission:/config \
    -v /MediaStore/Complete:/downloads \
    -v /MediaStore/Torrents:/watch \
    -v /MediaStore/Incomplete:/incomplete
    -e PGID=$GROUPID -e PUID=$USERID  \
    -e TZ="America/Edmonton" \
    -p 9091:9091 -p 50001:50001 \
    -p 50001:50001/udp \
    linuxserver/transmission
fi


[Service]
Restart=always
ExecStart=/usr/bin/docker start -a transmission
ExecStop=/usr/bin/docker stop -t 2 transmission

[Install]
WantedBy=default.target" >/etc/systemd/system/docker-transmission.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-transmission.service

systemctl start docker-transmission.service
