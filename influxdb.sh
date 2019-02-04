mkdir /local/media/influxdb

docker create \
  --name=influxdb \
  -v /local/media/influxdb:/var/lib/influxdb \
  -e PGID=1010 -e PUID=1010  \
  -p 8086:8086 \
  influxdb
  
  echo "[Unit]
Description=influxdb container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a influxdb
ExecStop=/usr/bin/docker stop -t 2 influxdb
[Install]
WantedBy=default.target" >/etc/systemd/system/docker-influxdb.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-influxdb.service
systemctl start docker-influxdb.service
