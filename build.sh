#!/bin/bash
#  Usage: ./build.sh
#  Description: Build docker containers for home plex environment
#  Author: Dustin Lactin/Randle Gold
#  Version 1.1
#  Created: Aug31, 2017
#-----------------------------------#
#-----------------------------------#

# Functions
install_docker () { 
 echo "Installing docker dependancies"
 apt-get install -y apt-transport-https ca-certificates
 echo "Adding gpg key for docker repository"
 apt-key adv \
               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D 
 echo "Adding apt repository for docker"
 echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
 echo "Updating repository cache"
 apt-get update
 echo "Installing recommended packages"
 apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual 
 echo "Installing docker" 
 apt-get install -y docker-engine
 echo "Starting docker service"
 service docker start
 echo "Docker install complete, run build.sh again to continue"
}

install_plex () { 
  echo "Downloading plex package"
  wget https://downloads.plex.tv/plex-media-server/1.3.3.3148-b38628e/plexmediaserver_1.3.3.3148-b38628e_amd64.deb -O /tmp/plexsrv.deb
  echo "Installing plex" 
  dpkg -i /tmp/plexsrv.deb
  if [[ -f "/local/media/plex/com.plexapp.plugins.library.db" ]]; then 
    echo "Restoring from backup"
    systemctl stop plexmediaserver
    rm -f "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db-shm"
    rm -f "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db-wal"
    cp /local/media/plex/com.plexapp.plugins.library.db "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases" 
    systemctl start plexmediaserver
    echo "Backup restored, plex install complete run build.sh again to continue" 
    exit
 fi
 echo "No backup found in /local/media/plex manual configuration will be required"
}

# Dependancy checking: 
`grep -E "Ubuntu 16.04" /etc/*lease &>/dev/null`
if [[ $? -ne 0 ]]; then 
  echo "ERROR: Build script is only compatible with Ubuntu 16.04"
  exit
fi

if [[ ! -d "/local/media" ]]; then 
  echo "ERROR: Mount media in /local/media"
  exit
fi

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

`dpkg -l plexmediaserver &>/dev/null`
if [[ $? -ne 0 ]]; then
  echo "ERROR: plex must be installed"
  echo "Install plex now? (y/n)"
  read input
  if [[ $input == "y" ]]; then
    install_plex
  else
    exit
  fi
fi

# Grab uid and gid for plex user
USERID=`id -u plex`
GROUPID=`id -g plex`

# Build Radarr

 docker create \
    --name=radarr \
    -v /local/media/radarr:/config \
    -v /MediaStore:/downloads \
    -v /MediaStore:/local/media \
    -e PGID=1010 -e PUID=1010  \
    -e TZ="America/Edmonton" \
    -p 7878:7878 \
linuxserver/radarr




# Restore and Build Sonarr
`docker inspect sonarr | grep -E 'running'`
if [[ $? -eq 1 ]]; then
  if [[ -f "/local/media/sonarr/backup.zip" ]]; then 
    echo "Installing dependancies" 
    apt-get install -y unzip
    echo "Restoring sonarr backup" 
    rm -f /local/media/sonarr/nzbdrone.db-wal
    rm -f /local/media/sonarr/nzbdrone.db-shm
    unzip -o /local/media/sonarr/backup.zip -d /local/media/sonarr
    chown -R plex.plex /local/media/sonarr
  fi
  
  docker create \
    --name sonarr \
    -p 8989:8989 \
    -e PUID=$USERID -e PGID=$GROUPID \
    -v /dev/rtc:/dev/rtc:ro \
    -v /local/media/sonarr:/config \
    -v /local/media:/local/media \
    -v /local/media/nzbget/downloads:/downloads \
    linuxserver/sonarr
fi

#build PlexRequest

docker create \
    --name=plexrequests \
    -v /etc/localtime:/etc/localtime:ro \
    -v /local/media/plexrequests:/config \
    -e PGID=1010 -e PUID=1010  \
    -p 3000:3000 \
linuxserver/plexrequests

#Build Plexypy

docker create \
  --name=plexpy \
  -v /local/media/plexpy:/config \
  -v /var/lib//plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Logs/:/logs:ro \
  -e PGID=1010 -e PUID=1010  \
  -e TZ="America/Edmonton" \
  -p 8181:8181 \
  linuxserver/plexpy

#Build Transmission

  docker create --name=transmission \
    -v /local/media/transmission:/config \
    -v /MediaStore/:/downloads \
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

echo "[Unit]
Description=sonarr container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a sonarr
ExecStop=/usr/bin/docker stop -t 2 sonarr
[Install]
WantedBy=default.target" >/etc/systemd/system/docker-sonarr.service

echo "[Unit]
Description=plexrequests container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a plexrequests
ExecStop=/usr/bin/docker stop -t 2 plexrequests
[Install]
WantedBy=default.target" >/etc/systemd/system/docker-plexrequests.service

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

echo "[Unit]
Description=radarr container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a radarr
ExecStop=/usr/bin/docker stop -t 2 radarr
[Install]
WantedBy=default.target" >/etc/systemd/system/docker-radarr.service

# Enable containers at system startup 
systemctl daemon-reload

systemctl enable docker-Plexpy.service
systemctl enable docker-radarr.service
systemctl enable docker-sonarr.service
systemctl enable docker-transmission.service
systemctl enable docker-plexrequests.service


systemctl start docker-Plexpy.service
systemctl start docker-transmission.service 
systemctl start docker-sonarr.service
systemctl start docker-radarr.service
systemctl start docker-plexrequests.service
