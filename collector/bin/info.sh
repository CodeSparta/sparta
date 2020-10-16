#!/bin/bash
info () {
bundleDu="$(du -h /root/deploy/bundle/koffer-bundle.openshift-*.tar | awk '{print $1}' | head -n 1)"
bundlePath="$(ls /root/deploy/bundle/koffer-bundle.openshift-*.tar | head -n 1 | sed 's/root\/deploy/tmp\/platform/')"
cat <<EOF

  Koffer Bundle Complete: ${bundleDu} ${bundlePath}

  Next Steps:
    - Move to cloudctl deployment services bastion \`/tmp\`
    - Unpack bundle into image registry path via cmd:

        \`tar xv -f /tmp/koffer-bundle.openshift-*.tar -C /root\`

EOF
}
info
