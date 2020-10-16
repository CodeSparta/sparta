#!/bin/bash -x
clear
project="collector-openshift"
sudo podman run -it --rm --pull always \
    --workdir /root/koffer \
    --volume $(pwd):/root/koffer:z \
    --name ${project} -h ${project} --entrypoint bash \
  docker.io/codesparta/koffer:latest

#   --volume ${HOME}/.aws:/root/.aws:z \
#   --volume ${HOME}/.docker:/root/.docker:z \
