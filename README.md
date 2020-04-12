Role Name
=========

ocp4-deploy: This role will be used to configure components for ocp4

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

| variable | default value |
| -------- | ------------- |
| awsRegion1 | "{{ lookup('ENV', 'awsRegion1') }}"
| awsRegion3 | "{{ lookup('ENV', 'awsRegion2') }}"
| awsRegion2 | "{{ lookup('ENV', 'awsRegion3') }}"
| dirArtifacts |"{{ lookup('ENV', 'dirArtifacts') }}"
| nameVpc |"{{ lookup('ENV', 'nameVpc') }}"
| nameDomain |"{{ lookup('ENV', 'nameDomain') }}"
| dirBase | "{{ lookup('ENV', 'dirBase') }}"
| clusterDomain |"{{ lookup('ENV', 'clusterDomain') }}"
| versOCP |"{{ lookup('ENV', 'versOCP') }}"
| nameCluster |"{{ lookup('ENV', 'nameCluster') }}"
| asset_directories | ${HOME}/PlatformOne/{mirror,images,repos,secrets,ansible,terraform |
| gitrepos | repo: `<`web url to http repo`>` dest: `<`path on filesystem where to place repo `>` |


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
jonny@redhat.com
