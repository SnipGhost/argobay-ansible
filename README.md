# High availability automated cluster 

Playbooks require secret variables:
- ansible_become_pass
- service_vip_password
- public_vip_password
- private_vip_password
- passwords
- ap_ssid
- ap_code
- ap_pass
- mariadb_sst_pass
- mariadb_clustercheck.user
- mariadb_clustercheck.pass
- haproxy_stat_user
- haproxy_stat_pass
- marusya_skill_db_name
- marusya_skill_db_user
- marusya_skill_db_pass
- smarthome_db_name
- smarthome_db_user
- smarthome_db_pass

passwords is dictionary with user passwords:
```yml
passwords:
  user_1: encrypted_string_x
  user_2: encrypted_string_y
```

+ ssl cert & key from {{default_cert}} & {{default_cert_key}}

## Use-cases

Run only logrotate & rsyslog on DEV:
```bash
ansible-playbook all_hosts.yml --tags "logrotate,rsyslog" -l dev
```

To update all components on DEV:
```bash
ansible-playbook setup.yml -l dev
```

To update all components on production [ATTENTION!]:
```bash
ansible-playbook setup.yml -l prod
```

To change passwords run:
```bash
ansible-playbook all_hosts.yml --tags common -e "set_passwords=yes"
```

To provision Raspberry Pi host:
```bash
ansible-playbook provision.yml -e "HOSTNAME=itsuki" -i 192.168.8.184,
```

Install mariadb first time [ATTENTION!]:
```bash
ansible-playbook storage.yml -e "mariadb_secure=yes mariadb_rejoin=yes mariadb_init=yes" -l dev
```

To re-setup marusya_skill [ATTENTION!]:
```bash
ansible-playbook assol.yml --tags marusya_skill -e "marusya_skill_setup=yes" -l dev
```

To re-setup smarthome [ATTENTION!]:
```bash
ansible-playbook assol.yml --tags smarthome -e "smarthome_setup=yes" -l dev
```

To download mdwiki run:
```bash
ansible-playbook web.yml --tags mdwiki -e "install_mdwiki=yes"
```

## Add new service role checklist

- Pull binary/script application
- Create application config
- Create application systemd unit
- Add nginx site config if needed
- Create DB if needed
- Change iptables for application
- Add new variables to group_vars
- Test application
- Pull exporter
- Create exporter systemd unit
- Change iptables for exporter
- Add exporter to prometheus_jobs
- Test exporter
- Commit
- Test all
- Push

## FAQ

### HAProxy stats page stuck loading
Re-auth on HAProxy stats page with http://user:pass@host:port/haproxy_stats

### Renew wildcard cert
PROD:
```bash
# @nino
certbot certonly -a certbot-dns-freenom:dns-freenom \
  --certbot-dns-freenom:dns-freenom-credentials /etc/letsencrypt/freenomdns.cfg \
  --certbot-dns-freenom:dns-freenom-propagation-seconds 600 \
  -d "*.assol.ml" -d "assol.ml"
```
DEV:
```bash
# @rikka
certbot certonly -a certbot-dns-freenom:dns-freenom \
  --certbot-dns-freenom:dns-freenom-credentials /etc/letsencrypt/freenomdns.cfg \
  --certbot-dns-freenom:dns-freenom-propagation-seconds 600 \
  -d "*.dev-assol.ml" -d "dev-assol.ml"
```

### Certbot import error
Install last certbot-nginx from pypi: https://pypi.org/project/certbot-nginx/#files

### Marusya skill tester
[Skill tester](https://skill-tester.marusia.mail.ru)

### Naming
[StarWars example](https://namingschemes.com/Star_Wars)

### GitHub auth/credentials
Not recommended password auth:
```
# File: ~/.netrc
machine github.com
login GIHUB_LOGIN
password GIHUB_PASSOWORD
```

Import ssh-key to ssh-agent (see `ssh-add -L`) and set ssh-origin
```bash
git remote set-url origin git@github.com:SnipGhost/assol-ansible.git 
```

### Add disk checklist
1) `fdisk`
2) `mkfs.ext4 /dev/sda2`
3) `mkdir -p /mnt/data`
4) `mount /dev/sda2 /mnt/data`
5) `lsblk -o NAME,UUID | grep sda2`
6) add to /etc/fstab automount
```ini
# SSD SMARTBUY 128 GiB
UUID=5ebb4c58-4f31-4081-9eed-ff3e86a69a02 /mnt/data ext4 defaults,auto,noatime,discard,rw,nofail 0 2
```

### Enable wi-fi on RPi
comment line `dtoverlay=disable-wifi` in /boot/config.txt

### Delete all old logs
```
find /var/log/ -name "*.gz" -type f -delete
```
