#!/bin/bash
#  Usage: ./build.sh
#  Description: Build docker containers for home plex environment
#  Author: Dustin Lactin 
#  Version 1.0 
#  Created: December 14th, 2016
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

# Restore and Build NZBGet
`docker inspect nzbget | grep -E 'running'`
if [[ $? -eq 1 ]]; then
  if [[ -f "/local/media/nzbget/nzbget.conf" ]]; then 
    echo "Existing nzbget configuration detected..."
    echo ""
  fi

  docker create \
    --name nzbget \
    -p 6789:6789 \
    -e PUID=$USERID -e PGID=$GROUPID \
    -e TZ="America/Edmonton" \
    -v /local/media:/local/media \
    -v /local/media/nzbget:/config \
    -v /local/media/nzbget/downloads:/downloads \
    linuxserver/nzbget
fi

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

# Build Couchpotato 
# Want to start fresh with couchpotato -- add restore function at some point
`docker inspect couchpotato | grep -E 'running'`
if [[ $? -eq 1 ]]; then
  docker create \
    --name=couchpotato \
    -v /local/media/couchpotato:/config \
    -v /local/media/nzbget/downloads:/downloads \
    -v /local/media/movies:/movies \
    -e PGID=$GROUPID -e PUID=$USERID  \
    -e TZ="America/Edmonton" \
    -p 5050:5050 \
    linuxserver/couchpotato
fi

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
Description=couchpotato container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a couchpotato
ExecStop=/usr/bin/docker stop -t 2 couchpotato
[Install]
WantedBy=default.target" >/etc/systemd/system/docker-couchpotato.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-nzbget.service
systemctl enable docker-sonarr.service
systemctl enable docker-couchpotato.service

systemctl start docker-nzbget.service
systemctl start docker-sonarr.service
systemctl start docker-couchpotato.service
