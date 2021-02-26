#!/bin/bash
dirPath="$(pwd)"
project="collector-sparta"
mkdir -p ${dirPath}/{bundle,.docker}
touch ${dirPath}/.gitconfig
clear && sudo podman run -it --rm --pull always \
    --name    ${project} -h ${project}                 \
    --volume  ${dirPath}:/root/koffer:z                \
    --volume  ${dirPath}/bundle:/root/bundle:z         \
    --volume  ${dirPath}/.docker:/root/.docker:ro      \
    --volume  ${dirPath}/.gitconfig:/root/.gitconfig:z \
    --workdir /root/koffer --entrypoint bash           \
  quay.io/cloudctl/koffer:latest
