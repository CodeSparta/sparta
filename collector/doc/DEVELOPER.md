# TPDK Developer | OpenShift IaC Plugin
### Prerequisites:
  - [Podman]
  - [~/.gitconfig] configured with [token]
  - [~/.docker/config.json]

## Koffer developer workflow
  1. Clone Plugin
```
 git clone https://github.com/CodeSparta/openshift.git && cd openshift
```
  2. Exec into Koffer container
```
 source collector/tools/dev.sh
```
  3. Manually start supporting services
```
 source collector/tools/entrypoint.sh
```
  4. Start Koffer collector plugin:
```
Example A) Collect a tagged release of Sparta Trusted Platform Delivery Kit
 ./collector/site.yml -e tpdk_version=4.5.11 -vv

Example B) Collect the latest konductor & master development branch
 ./collector/site.yml -e konductor_version=latest -e tpdk_version=master -vv
```

[token]:https://github.com/settings/tokens
[~/.gitconfig]:https://github.com/CodeSparta/devkit/blob/master/docs/gitconfig.md
[~/.docker/config.json]:https://github.com/CodeSparta/devkit/blob/master/docs/quay_pull_secret.md
[Podman]:https://podman.io/getting-started/installation.html
