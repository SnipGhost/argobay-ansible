# High availability automated cluster 

Playbooks require secret variables:
- ansible_become_pass
- service_vip_password
- public_vip_password
- ap_ssid
- ap_pass
- ap_code
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

To provision Raspberry Pi host:
```bash
ansible-playbook provision.yml -e "HOSTNAME=itsuki" -i 192.168.8.184,
```

Install mariadb first time:
```bash
ansible-playbook db_servers.yml -e "mariadb_secure=yes mariadb_rejoin=yes mariadb_init=yes"
```
