OCP4 Deploy
=========

This role configures the local system in order to launch containerONE; a container image used for provisioning, bootstrapping and configuration OpenShift 4 node types to support a full deployment. 

Requirements
------------

The following table outlines the software requirements and versions used to run this role.

| Package | Version |
| ------- | ------- |
| ansible | 2.9.2   | 
| podman  | 1.6.4   |
| python  | 3.7.4   |

Role Variables
--------------

| variable | mapped_value | default value |
| -------- | ------------- | ------------ |
| awsRegion1 | reserved_for_future_regions | "{{ lookup('ENV', 'awsRegion1') }}" |
| awsRegion3 | reserved_for_future_region  | "{{ lookup('ENV', 'awsRegion2') }}" |
| awsRegion2 | reserved_for_future_regions | "{{ lookup('ENV', 'awsRegion3') }}" |
| dirArtifacts | artifact_directory | "{{ lookup('ENV', 'dirArtifacts') }}" |
| nameVpc | vpc_name | "{{ lookup('ENV', 'nameVpc') }}" |
| nameDomain | domain_name | "{{ lookup('ENV', 'nameDomain') }}" |
| dirBase | base_directory | "{{ lookup('ENV', 'dirBase') }}" |
| clusterDomain | cluster_domain | "{{ lookup('ENV', 'clusterDomain') }}" |
| versOCP | ocp_version | "{{ lookup('ENV', 'versOCP') }}"|
| nameCluster | cluster_name | "{{ lookup('ENV', 'nameCluster') }}" |
| home_directory | no mapping | "{{ lookup('ENV', 'HOME') }}" |
| tf_base_dir | no mapping | "{{ lookup('ENV', 'dirBase') }}/terraform/aws-platform-{base,openshift4-registry,openshift4-bootsrap,openshift4-masters}"

Example Playbook
----------------
```yaml
---
- name: ocp4-deploy | Install and Configure OCP4
  hosts: localhost
  connection: local
  tasks:
    - name: ocp4-deploy | Import OCP4 init role
      include_role: ./roles/task01-init
      tags:
        - init

    - name: ocp4-deploy | Import OCP4 config role
      include_role: ./roles/task02-config
      tags:
        - config

    - name: ocp4-deploy | Import OCP4 deploy role
      include_role: ./roles/task03-deploy
      tags:
        - deploy
```

License
-------

BSD

Author Information
------------------
platformONE@redhat.com 
Specifically the following people:
* jonny@redhat.com
* mholmes@redhat.com
* jhultz@redhat.com
* dino@redhat.com
* kmorgan@redhat.com
* dlystra@redhat.com
* mradecker@redhat.com

