# High availability automated cluster 


## Init repo

1) Create [secrets files](docs/vault.md) for all, prod and dev
2) `ansible-galaxy install -r requirements.yml`


## Add new service role checklist

- Pull binary/script application
- Create application config
- Create application systemd unit
- Add nginx site config if needed
- Create DB if needed
- Change iptables for application
- Add new variables to group_vars
- Add secrets to prod, dev & all secret file
- Add secrets examples to docs/vault.md
- Test application
- Pull exporter
- Create exporter systemd unit
- Change iptables for exporter
- Add exporter to prometheus_jobs
- Test exporter
- Commit
- Test all
- Push


## Install ansible on Raspberry Pi
```bash
echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list
curl -sL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x93C4A3FD7BB9C367" | apt-key add
apt install python-dnspython ansible
```


## Use-cases

### Simple

Run any script on specified servers:
```bash
ansible -mraw -a 'apt update' all
```

```bash
ansible -mraw -a 'COMMAND' GROUP
```

### All components

To update all components on DEV:
```bash
ansible-playbook setup.yml -l dev
```

To update all components on production [ATTENTION!]:
```bash
ansible-playbook setup.yml -l prod
```

### Everyday affairs

Run only logrotate & rsyslog on DEV:
```bash
ansible-playbook playbooks/all_hosts.yml --tags "logrotate,rsyslog" -l dev
```

To change passwords run:
```bash
ansible-playbook playbooks/all_hosts.yml --tags common -e "set_passwords=yes"
```

To provision Raspberry Pi host:
```bash
# Update DNS before run to generate valid dhcpd.conf with provision.sh
ansible-playbook playbooks/service.yml --tags dns

# Change hostname and IP
./provision.sh rapunzel 192.168.8.116

# Run common roles
ansible-playbook playbooks/all_hosts.yml -e "set_passwords=yes" -l rapunzel

# Additional run raspberry pi specific roles
ansible-playbook playbooks/raspberry.yml -l rapunzel
# And update monitoring configs
ansible-playbook playbooks/monitroing.yml --tags prometheus
```

To update dns:
```bash
ansible-playbook playbooks/service.yml --tags dns
```

To update nginx:
```bash
ansible-playbook playbooks/web.yml -l dev --tags nginx
```

To deploy renewed certs:
```bash
ansible-playbook playbooks/letsapi.yml --tags certs
```

Install mariadb first time [ATTENTION!]:
```bash
ansible-playbook playbooks/storage.yml -e "mariadb_secure=yes mariadb_rejoin=yes mariadb_init=yes" -l dev
```

To re-setup krionard [ATTENTION!]:
```bash
ansible-playbook playbooks/omega.yml --tags krionard -e "krionard_setup=yes" -l dev
```

To re-setup dacrover [ATTENTION!]:
```bash
ansible-playbook playbooks/omega.yml --tags dacrover -e "dacrover_setup=yes" -l dev
```

To re-setup razumator [ATTENTION!]:
```bash
ansible-playbook playbooks/razumator.yml -e "razumator_setup=yes" -l dev
```

To download mdwiki run:
```bash
ansible-playbook playbooks/web.yml --tags mdwiki -e "install_mdwiki=yes"
```

To re-register GitLab runner:
```bash
ansible-playbook playbooks/runner.yml
```
