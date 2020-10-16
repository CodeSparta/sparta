#!/bin/bash -x

project="collector-openshift"
clear && mkdir -p /tmp/bundle

sudo podman run -it --rm --pull always \
    --name ${project} -h ${project} \
    --volume $(pwd):/root/koffer:z \
    --volume /tmp/bundle:/root/bundle:z \
    --workdir /root/koffer --entrypoint bash \
    --volume ${HOME}/.docker:/root/.docker:ro \
    --volume ${HOME}/.gitconfig:/root/.gitconfig:z \
  docker.io/codesparta/koffer:latest

#   --volume ${HOME}/.aws:/root/.aws:z \
#   --volume ${HOME}/.docker:/root/.docker:z \
