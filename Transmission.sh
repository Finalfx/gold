
#!/bin/bash
#  Usage: ./build.sh
#  Description: Build docker container for Trans
#  Author: Randle Gold 
#  Version 1.0 
#  Created: March 26, 2017
#-----------------------------------#
#-----------------------------------#

# Functions
`dpkg -l docker &>/dev/null`
if [[ $? -ne 0 ]]; then 
  echo "ERROR: Docker must be installed"
  echo "Install docker now? (y/n)"
  read input
  if [[ $input == "y" ]]; then
    install_docker
  else
    exit
  fi
fi

# Grab uid and gid for plex user
USERID=`id -u plex`
GROUPID=`id -g plex`

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
systemctl daemon-reload
systemctl enable docker-transmission.service
systemctl start docker-transmission.service
