#!/bin/bash
#  Usage: ./build.sh
#  Description: Build docker container for Unifi Conroller
#  Author: Randle Gold 
#  Version 1.0 
#  Created: Dec2, 2017
#-----------------------------------#
#-----------------------------------#

# Functions


# Grab uid and gid for plex user
#USERID=`id -u plex`
#GROUPID=`id -g plex`

docker create \
  --name=unifi \
  -v /local/media/unifi:/config \
  -e PGID=1010 -e PUID=1010  \
  -p 3478:3478/udp \
  -p 10001:10001/udp \
  -p 8080:8080 \
  -p 8081:8081 \
  -p 8443:8443 \
  -p 8843:8843 \
  -p 8880:8880 \
  linuxserver/unifi
