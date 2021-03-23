Typical troubleshooting:
```sh
# on the cloudctl host as root
podman logs registry
podman logs nginx
podman images
podman ps

# in konductor
curl -k http://registry.usrbinkat.codectl.io:8080/master.ign
curl -ku 'cloudctl:cloudctl' https://registry.usrbinkat.codectl.io:5000/v2/_catalog
oc get co

# get logs from bootstrap
ssh -i /root/platform/secrets/ssh/id_rsa_kubeadmin core@${bootstrap_ipv4_address}
sudo podman images
sudo journalctl -b -f -u release-image.service -u bootkube.service
```
