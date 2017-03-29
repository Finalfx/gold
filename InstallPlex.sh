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
