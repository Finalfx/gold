#!/bin/bash
#  Usage: ./build.sh
#  Description: Build docker container for Watchtower
#  Author: Randle Gold 
#  Version 1.0 
#  Created: Oct 22, 2017
#-----------------------------------#
#-----------------------------------#

# Functions


# Grab uid and gid for plex user
#USERID=`id -u plex`
#GROUPID=`id -g plex`

docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  v2tec/watchtower -i 86400 --cleanup
