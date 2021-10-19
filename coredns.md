#  CodeSparta CoreDNS Install

## Devkit VPC
1. Clone Sparta Devkit VPC repo
```
git clone --branch devkit_coredns https://github.com/CodeSparta/devkit-vpc.git && cd devkit-vpc
```
2. Configure variables
```
vi variables.tf
```
3. Exec into Konductor IaC Runtime
```
./devkit-build-vpc.sh -vv -e aws_cloud_region=us-gov-west-1 \
 -e aws_access_key=xxxxxxxxxxxxx -e aws_secret_key=XXXXXXXXXXXXXXXXX
 ```
## Low Side Bundle
1. Push AWS SSH keys to “low side” RHEL Bastion
```
scp -i ~/.ssh/${keyname} ~/.ssh/${keyname}* ec2-user@${rhel_bastion_public_ip}:~/.ssh/
```
2. SSH to the RHEL bastion
```
ssh -i ~/.ssh/${keyname} ec2-user@${rhel_bastion_public_ip}
```
3. Ensure Podman is installed
```
sudo dnf install -y podman
```
4. Create Platform Artifacts Staging Directory
```
mkdir -p ${HOME}/bundle
```
5. curl coredns.sh
```
curl -o ${HOME}/bundle/coredns.sh https://raw.githubusercontent.com/CodeSparta/sparta/coredns/coredns.sh
```
6. Build Koffer Bundles for CloudCtl, OCP Platform Infra, and Sparta IaC
```
podman run -it --rm --pull always \
--volume ${HOME}/bundle:/root/bundle:z \
quay.io/cloudctl/koffer:v00.21.0803 bundle \
--config https://codectl.io/docs/config/stable/sparta.yml \
-v "latest-4.7"
```
7. Paste [Quay.io Image Pull Secret](https://cloud.redhat.com/openshift/install/metal/user-provisioned) when prompted

8. Set Permissions on bundle(s)
```
sudo chown -R $USER $(pwd)/bundle
```
9. Review your artifacts
```
du -sh $(pwd)/bundle/*
```
## Airgap Artifact Walk
1. Push artifact bundles to “high side” RHCOS private registry node
```
rsync --progress -avzh bundle -e "ssh -i ~/.ssh/${keyname}" core@${rhcos_private_registry_node_ip}:~
```
2. SSH to the “high side” RHCOS CloudCtl private deployment services node
```
ssh -i ~/.ssh/${keyname} core@${rhcos_private_registry_node_ip}
```
3. Extract bundles
```
sudo tar xvf ${HOME}/bundle/koffer-bundle.sparta-*-*.tar -C /root
```
4. Copy coredns.sh to /root/platform/iac/sparta
```
sudo cp ${HOME}/bundle/coredns.sh /root/platform/iac/sparta/coredns.sh
```
## High-Side Deployment
1. Acquire root
```
sudo -i
```
2. Change directory to /root/cloudctl and change start_dns var to true
```
cd /root/cloudctl; sed -i 's/start_dns: false/start_dns: true/g' vars/run.yml
```
3. Run init.sh
```
./init.sh
```
4. Exec into Konductor
```
podman exec -it konductor connect
```
4. Assign variables
```
vim /root/platform/iac/cluster-vars.yml
```
5. Change directory to /root/platform/iac/sparta
```
cd /root/platform/iac/sparta
```
6. Need to update the endpoints.json on the konductor container prior to kicking off coredns.sh (sed -i 's/gov-west/gov-east/g' /usr/local/lib/python3.6/site-packages/boto/endpoints.json)
7. Need to update the dns resolver on the registry node (volume mounted to the container):
   - /root/platform/iac/sparta/vars/global.yml:dns_forward_ipv4: "{{ dns_forwarder | default('yourResolverIP') }}"
   - /root/cloudctl/vars/global.yml:dns_forwarder: "{{ dns_forward_ipv4 | default('yourResolverIP') }}"
8. Run coredns.sh
```
chmod +x coredns.sh; ./coredns.sh
```
9. Waiting for ingress-router will eventually fail.  Need to add the proper search domain and IP of the registry bastion to the konductor /etc/resolv.conf
10. Once the internal ELB fqdn is obtained (from the konductor container: oc get svc -n openshift-ingress | awk '/router-default/{print $4}'), add the value to the core.db on the registry bastion
   /root/platform/coredns/core.db and restart the coredns pod
```
podman restart coredns
```
11. Watch Cluster Operators come online (may take 30-60 minutes)
```
watch oc get co
```
12. Also watch for & add Apps ELB DNS CNAME `*.apps.cluster.domain.com` wildcard [DNS Entry](https://console.amazonaws-us-gov.com/route53/home?#resource-record-sets)
```
oc get svc -n openshift-ingress | awk '/router-default/{print $4}'
```

## Cluster & VPC Teardown

1. Exec into container
```
 sudo podman exec -it konductor bash
```
2. Change dir into Terraform Directory
```
 cd /root/platform/iac/shaman
```
3. Patch masters to make scheduleable
```
oc patch schedulers.config.openshift.io cluster -p '{"spec":{"mastersSchedulable":true}}' --type=merge
```
4. Delete machinesets & wait for worker nodes to terminate
```
for i in $(oc get machinesets -A | awk '/machine-api/{print $2}'); do oc delete machineset $i -n openshift-machine-api; echo deleted $i; done
```
5. Delete service router & wait for it to terminate
```
oc delete service router-default -n openshift-ingress &
```
6. Modify breakdown.yml
```
sed -i '/route53/d' breakdown.yml
```
7. Exec control plane breakdown playbook
```
 chmod +x ./breakdown.yml && ./breakdown.yml
```
