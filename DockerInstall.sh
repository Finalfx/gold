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
