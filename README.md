# High availability automated cluster 

Playbooks require secret variables:
- ansible_become_pass
- service_vip_password
- public_vip_password
- private_vip_password
- monitoring_vip_password
- research_vip_password
- dev_public_vip_password
- dev_private_vip_password
- passwords
- ap_ssid
- ap_code
- ap_pass
- mariadb_sst_pass
- mariadb_clustercheck.user
- mariadb_clustercheck.pass
- haproxy_stat_user
- haproxy_stat_pass
- krionard_db_name
- krionard_db_user
- krionard_db_pass
- dacrover_db_name
- dacrover_db_user
- dacrover_db_pass
- razumator_db_name
- razumator_db_user
- razumator_db_pass
- alertmanager_bot_telegram_token
- gitlab_runner_reg_token
- payment_exporter_user
- payment_exporter_pass
- htpasswd
- rsync_certs_user
- rsync_certs_pass

passwords is dictionary with user passwords:
```yml
passwords:
  user_1: encrypted_string_x
  user_2: encrypted_string_y
```

+ ssl cert & key from {{default_cert}} & {{default_cert_key}}


## Init repo

1) Create secrets files for all, prod and dev
2) `ansible-galaxy install -r requirements.yml`


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
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook provision.yml -e "HOSTNAME=zelda rpi_disable_wireless=yes" -i 192.168.8.144,
unset ANSIBLE_HOST_KEY_CHECKING
```

To update dns:
```bash
ansible-playbook service.yml --tags dns
```

To update nginx:
```bash
ansible-playbook web.yml -l dev --tags nginx
```

To deploy renewed certs:
```bash
ansible-playbook letsapi.yml --tags certs
```

Install mariadb first time [ATTENTION!]:
```bash
ansible-playbook storage.yml -e "mariadb_secure=yes mariadb_rejoin=yes mariadb_init=yes" -l dev
```

To re-setup krionard [ATTENTION!]:
```bash
ansible-playbook assol.yml --tags krionard -e "krionard_setup=yes" -l dev
```

To re-setup dacrover [ATTENTION!]:
```bash
ansible-playbook assol.yml --tags dacrover -e "dacrover_setup=yes" -l dev
```

To re-setup razumator [ATTENTION!]:
```bash
ansible-playbook razumator.yml -e "razumator_setup=yes" -l dev
```

To download mdwiki run:
```bash
ansible-playbook web.yml --tags mdwiki -e "install_mdwiki=yes"
```

To re-register GitLab runner:
```bash
ansible-playbook runner.yml
```

Run any script on specified servers:
```bash
ansible -mraw -a 'apt update' all
```

```bash
ansible -mraw -a 'COMMAND' GROUP
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
And fix binary path in /lib/systemd/system/certbot.service
And in cron.d/certbot

### Marusya tester
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

### Import ssh-keys
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

### Install ansible
```bash
echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list
curl -sL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x93C4A3FD7BB9C367" | apt-key add
apt install python-dnspython ansible
```

### Install tensorflow==1.15.3 on RPi
```bash
pip uninstall tensorflow
pip3 uninstall tensorflow
apt install libhdf5-dev libc-ares-dev libeigen3-dev libatlas-base-dev libatlas3-base
pip3 install h5py==2.10.0
wget https://github.com/Qengineering/Tensorflow-Raspberry-Pi/raw/master/tensorflow-1.15.2-cp37-cp37m-linux_armv7l.whl
pip3 install tensorflow-1.15.2-cp37-cp37m-linux_armv7l.whl
```

### Prometheus 1.x instead of 2.x
So, mmap's in new Prometheus caused `mmap: cannot allocate memory` errors and panics on 32-bit systems.
You can check the developer's answers about this - they have no plans to support 32 bit architectures.
It is suggested to use 1.x version of Prometheus to avoid problems.
Workaround is empirically reduce the retention size and scrap intervals.
https://github.com/prometheus/prometheus/issues/7483
https://github.com/prometheus/prometheus/issues/4392

UPD: Bad news - 1.8.2 has extremely outdated configuration. Suggest to use Victoria Metrics

### Telegram bot
Bot_name: @assol_ml_bot

### Make multiple remote upstreams
```bash
GROUP=infrastructure
PROJECT=assol-ansible

git remote add bmstu git@bmstu.codes:iu5/${GROUP}/${PROJECT}.git
git config --global alias.pushall '!git remote | xargs -L1 git push --all'

git pushall
```

### Start gitlab-runner manually
Go to `gitlab_runner_install_dir` and run docker-compose, for example:
```bash
cd /mnt/data/runners/arm-runner/
docker-compose up -d
```

### Stopwatch and countdown
```bash
function countdown(){
   date1=$((`date +%s` + $1)); 
   while [ "$date1" -ge `date +%s` ]; do 
     echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
     sleep 0.1
   done
}
function stopwatch(){
  date1=`date +%s`; 
   while true; do 
    echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r"; 
    sleep 0.1
   done
}
```

### Create htpasswd file
```bash
htpasswd -c htpasswd admin
```

### Create ceph logical volume
```bash
pvcreate /dev/sda1
vgcreate cephvg /dev/sda1
lvcreate --name cephlv -l 100%FREE cephvg
```

### Create crush tree
```bash
ceph osd crush add-bucket prod-root root
ceph osd crush add-bucket dev-root root
ceph osd crush add-bucket prod-home datacenter
ceph osd crush move prod-home root=prod-root
ceph osd crush add-bucket dev-home datacenter
ceph osd crush move dev-home root=dev-root
ceph osd crush add-bucket asuna host
ceph osd crush add-bucket ichika host
ceph osd crush add-bucket zelda host
ceph osd crush add-bucket itsuki host
ceph osd crush move asuna datacenter=prod-home
ceph osd crush move ichika datacenter=prod-home
ceph osd crush move zelda datacenter=prod-home
ceph osd crush move itsuki datacenter=prod-home
ceph osd crush rule create-replicated prod-rule prod-root osd ssd
ceph osd crush set osd.0 0.080 root=prod-root datacenter=prod-home host=asuna
ceph osd crush set osd.1 0.080 root=prod-root datacenter=prod-home host=ichika
ceph osd crush set osd.2 0.080 root=prod-root datacenter=prod-home host=zelda
ceph osd crush set osd.3 0.080 root=prod-root datacenter=prod-home host=itsuki
```

### Create CephFS
```bash
ceph osd pool create cephfs_data 64
ceph osd pool create cephfs_metadata 16
ceph fs new cephfs cephfs_metadata cephfs_data
ceph fs ls
```

### Mount CephFS
Available only with module ceph in /lib/modules/
Core: 5.10.27-v7l-ceph+

```bash
mount -t ceph zelda:6789,asuna:6789,ichika:6789:/ /mnt/cephfs -o name=admin,secretfile=/etc/ceph/admin.secret,noatime
```

### Enable Ceph monitoring
```bash
ceph mgr module enable prometheus
```
