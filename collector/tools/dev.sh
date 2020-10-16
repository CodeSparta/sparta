#!/bin/bash -x
clear
project="collector-infra"
sudo podman run -it --rm --pull always \
    --workdir /root/platform/iac/${project} \
    --volume $(pwd):/root/platform/iac/${project}:z \
    --name ${project} -h ${project} --entrypoint bash \
  docker.io/codesparta/koffer:latest

#   --volume $(pwd)/aws/:/root/.aws/:z \
