# TPDK Plugin | OpenShift Deployment IaC
### Prerequisites:
  - [Podman]

## Low Side) Build offline Koffer bundle

  1. Run Koffer `openshift` plugin
```
 mkdir -p ${HOME}/bundle && \
 podman run -it --rm --pull always \
     --volume ${HOME}/bundle:/root/bundle:z \
   docker.io/cloudctl/koffer:latest bundle \
     --plugin openshift
```

  2. Check bundle
```
 du -sh ${HOME}/bundle/koffer-bundle.openshift-*.tar.xz
```

## High Side) Deploy from bundled artifacts
  1. Extract bundle
```
 sudo tar -xv -f /tmp/koffer-bundle.openshift-*.tar -C /root
```
  2. Exec to root
```
 sudo -i
```
  3. Declare variables
```
 vi ./answer.sh
```
  4. Start Deploy
```
 ./konductor.sh
```
  5. Exec into konductor
```
 podman exec -it konductor connect
```
  6. Monitor cluster operators
```
 watch oc get co
```

[Podman]:https://podman.io/getting-started/installation.html
