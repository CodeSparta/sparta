# [Koffer](https://github.com/containercraft/Koffer) Collector | OpenShift Infrastructure Artifacts
This automation provides a unified and standardized tarball of artifacts for
airgap infrastructure deployment tasks. Included is the restricted environment
delivery services `CloudCtl` pod & `start-cloudctl.sh` script.

Features:
  - High side sha256 verification of artifacts bundle before standup
  - High side artifact delivery via script to run `cloudctl` podman pod running:
    - Nginx for serving CoreOS Ignition files
    - Generic Docker Registry:2 for serving pre-hydrated image content
    - ContainerOne user automation deployment and development workspace
  - Bastion host support for CoreOS or any Podman capable distribution
  - Low side injestion direct to "pre-hydrated" registry stateful path

## Instructions:
### 1. Run Infrastructure Collector with Koffer Engine
```
 mkdir -p /tmp/platform ; \
sudo podman run -it --rm \
    --volume /tmp/bundle:/root/deploy/bundle:z \
  docker.io/codesparta/koffer bundle \
    --repo collector-infra@master

```
### 2. Move Koffer Bundle to target host `${USER}` directory
# [Developer Docs & Utils](./dev)
