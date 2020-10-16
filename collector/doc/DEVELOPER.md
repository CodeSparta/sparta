# TPDK Developer | OpenShift IaC Plugin
### Prerequisites:
  - [Podman]
  - [.gitconfig] configured with [token]

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
 source collector/tools/emulate.sh
```
  4. Start Koffer collector plugin:
```
Example A) Collect a tagged release of Sparta Trusted Platform Delivery Kit
 ./collector/site.yml -e tpdk_version=4.5.11 -vv

Example B) Collect the latest konductor & master development branch
 ./collector/site.yml -e konductor_version=latest -e tpdk_version=master -vv
```

[token]:https://github.com/settings/tokens
[.gitconfig]:https://github.com/CodeSparta/devkit/blob/master/docs/gitconfig.md
[Podman]:https://podman.io/getting-started/installation.html
