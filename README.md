# High availability automated cluster 

Playbooks require secret variables:
- ansible_become_pass
- service_vip_password
- public_vip_password
- passwords

passwords is dictionary:
```yml
passwords:
  user_1: encrypted_string_x
  user_2: encrypted_string_y
```

To change passwords run:
```bash
ansible-playbook setup.yml --tags common -e "set_passwords=yes"
```
