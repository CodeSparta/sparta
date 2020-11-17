bin/entrypoint:    git checkout nightlies;
DEVELOPER.md:  docker.io/cloudctl/koffer:nightlies
DEVELOPER.md:  docker.io/cloudctl/koffer:nightlies
DEVELOPER.md: git checkout nightlies
DEVELOPER.md:sudo podman rmi --force koffer:nightlies
README.md:  docker.io/cloudctl/koffer:nightlies
vars/images.yml:    tag: nightlies
templates/pod/cloudctl.yml.j2:    image: quay.io/cloudctl/one:nightlies
