docker create \
    --name netdata \
    --net=host \
    -d --cap-add SYS_PTRACE \
    -v /proc:/host/proc:ro \
    -v /sys:/host/sys:ro \
    -p 19999:19999
    -e PUID=1010 -e PGID=1010 \
    titpetric/netdata

echo "[Unit]
Description=netdata container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a netdata
ExecStop=/usr/bin/docker stop -t 2 netdata
[Install]
WantedBy=default.target" >/etc/systemd/system/docker-netdata.service

# Enable containers at system startup 
systemctl daemon-reload
systemctl enable docker-netdata.service
systemctl start docker-netdata.service
