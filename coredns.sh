#!/bin/bash

cat <<EOF > /root/platform/iac/sparta/optionset.yml
---
- name: Set DHCP Option Set
  hosts: cloudctl
  vars_files:
  - '../cluster-vars.yml'
  - 'vars/global.yml'
  - 'vars/{{ target_environment }}.yml'
  vars:
    listen_address: "{{ lookup('env', 'PUBLISH_ADDRESS') | default(ansible_default_ipv4.address, true) }}"
  tasks:  
    - name: set ec2 dns optionset
      amazon.aws.ec2_vpc_dhcp_option:
        aws_access_key: "{{ aws_access_key_id }}"
        aws_secret_key: "{{ aws_secret_access_key }}"
        domain_name: "{{ cluster_domain }}"
        region: "{{ aws_region }}"
        vpc_id: "{{ vpc_id }}"
        dns_servers:
          - "{{ listen_address }}"
        inherit_existing: True
        delete_old: True
        tags:
          Name: "cloudctl-{{ vpc_name }}"
      delegate_to: konductor
EOF

cat <<EOF > /root/platform/iac/sparta/shaman.yml
#!/usr/local/bin/ansible-playbook

- name: ' Konductor UPI '
  hosts: konductor
  vars_files:
  - '../cluster-vars.yml'
  - 'vars/global.yml'
  - 'vars/{{ target_environment }}.yml'
  vars:
    module: "build"
    state_provider: "local"
    tf_module_path: "{{ dir_terraform }}/shaman"
    vars_module_path: "{{ dir_terraform }}"
    ansible_name_module: " Konductor | UPI | {{ module }}"
  tasks:
    ####### Terraform Apply
    - name: '{{ ansible_name_module }} | terraform | apply'
      terraform:
        project_path: "{{ item }}"
        variables_file: "{{ vars_module_path }}/global.tfvars"
        state: present
      loop:
        - "{{ tf_module_path }}/elb"
        - "{{ tf_module_path }}/control-plane"
      register: tf_output
EOF

cat <<EOF > /root/platform/iac/sparta/roles/coredns/tasks/aws.yml
---
- name: Gather information about all ELBs
  community.aws.elb_application_lb_info:
    names: "{{ cluster_name }}-int"
    region: "{{ aws_region }}"
    aws_access_key: "{{ aws_access_key_id }}"
    aws_secret_key: "{{ aws_secret_access_key }}"
  register: elb_int
  delegate_to: konductor

- name: 'set fact'
  set_fact:
    elb_int_fqdn: "{{ elb_int.load_balancers | map(attribute='dns_name') | first }}"
  delegate_to: konductor
EOF

cat <<EOF > /root/platform/iac/sparta/ingress.yml
#!/usr/local/bin/ansible-playbook

- name: 'Ingress'
  hosts: konductor
  vars_files:
  - '../cluster-vars.yml'
  - 'vars/global.yml'
  - 'vars/{{ target_environment }}.yml'
  tasks:
    - name: Waiting for default ingress to be defined...
      k8s_info:
        api_version: v1
        kind: Service
        name: router-default
        namespace: openshift-ingress
      register: ingress_status_out
      until:
      - ingress_status_out is defined
      - ingress_status_out.resources[0] is defined
      - ingress_status_out.resources[0].status.loadBalancer.ingress[0].hostname is defined
      retries: 120
      delay: 10
      
    - name: Set ingress_hostname fact
      set_fact:
        elb_name: "{{ ingress_status_out.resources[0].status.loadBalancer.ingress[0].hostname }}"

    - name: Add var to cloudctl host
      add_host:
        name: "cloudctl"
        elb_name: "{{ elb_name }}"

- name: '{{ ansible_name }} | coredns.yml' 
  hosts: cloudctl
  vars_files:
    - 'vars/global.yml'
    - 'vars/run.yml'
    - '../cluster-vars.yml'
  vars:
    module: "coredns"
    ansible_name_module: "{{ ansible_name }} | {{ module }}"
    listen_address: "{{ lookup('env', 'PUBLISH_ADDRESS') | default(ansible_default_ipv4.address, true) }}"
  tasks:
    - name: '{{ ansible_name_module }} | template | Build CoreDNS config.yml' 
      template:
        src: '{{ item.src }}'
        dest: '{{ item.dest }}'
        mode: '{{ item.mode }}'
      loop: 
      - { mode: '0655', src: "coredns/config.json.j2", dest: "{{ dir_platform }}/coredns/config.json"}
      - { mode: '0655', src: "coredns/core.db.j2", dest: "{{ dir_platform }}/coredns/core.db"}

    - name: '{{ ansible_name_module }} | cmd:podman_container | Podman create {{ module }}' 
      containers.podman.podman_container:
        detach: yes
        name: "coredns"
        pod: "cloudctl"
        state: "started"
        recreate: "true"
        image: "{{ upstream_registry }}/cloudctl/coredns"
        volume:
          - "{{ dir_platform }}/coredns/config.json:/CoreFile:z"
          - "{{ dir_platform }}/coredns/core.db:/core.db:z"
EOF

cat <<EOF > /root/platform/iac/sparta/site.yml
#!/usr/local/bin/ansible-playbook
- name: 'RedHat | Konductor | site.yml'
  hosts: koffer

- import_playbook: optionset.yml   # Create DHCP optionset
- import_playbook: tree.yml        # Create base deployment directory tree 
- import_playbook: ssl.yml         # Stage deployment secrets
- import_playbook: secrets.yml     # Stage deployment secrets
- import_playbook: templates.yml   # Template prerequisite configs & auxillary manifests 
- import_playbook: registry.yml    # Restart registry with new certificate
- import_playbook: manifests.yml   # Create & customize OpenShift manifest files
- import_playbook: ignition.yml    # Build RH CoreOS ignition files from manifests
- import_playbook: shaman.yml      # Build the ELB and OCP Control plane via Terraform
- import_playbook: dns.yml         # Configure CoreDNS "BYO DNS" Deploy time NS
- import_playbook: ingress.yml     # Adds DNS entry for ingress
EOF

sed -i 's/{{ elb_name | default(null) }}/{{ elb_name if elb_name is defined }}/g' /root/platform/iac/sparta/templates/coredns/core.db.j2

./site.yml