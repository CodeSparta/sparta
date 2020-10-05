# clusterpost
Repository for playbooks ..etc to run after cluster installation has completed.

### Using the k8s ansible module
To use the k8s ansible module you will need to install the openshift python module for python3. 

```python
pip3 install openshift
```
### Example playbook
```yaml
#!/usr/bin/ansible-playbook -vv
- name: test
  hosts: localhost
  vars:
    - ansible_python_interpreter: /usr/bin/python3
  gather_facts: false
  tasks:
    - name: patch 
      k8s:
        definition:
          apiVersion: v1
          kind: ConfigMap
          metadata:
            name: my-configMap
            namespace: my-nameSpace
          data:
            disabled: "true"
```

This example assumes that a valid cluster config is exported as an environment variable or placed in `~/.kube/config`.

#### What is happening in the example?
The equivalent of `oc patch` is being run against the configMap and changing whatever value currently exists (i.e., `false`) and setting it to `true`
