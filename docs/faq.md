# Frequent problems & operations guide


## HAProxy stats page stuck loading
Re-auth on HAProxy stats page with http://user:pass@host:port/haproxy_stats


## Certbot import error
Install last certbot-nginx from pypi: https://pypi.org/project/certbot-nginx/#files
And fix binary path in /lib/systemd/system/certbot.service
And in cron.d/certbot


## Renew wildcard cert
PROD:
```bash
# @nino
certbot certonly -a certbot-dns-freenom:dns-freenom \
  --certbot-dns-freenom:dns-freenom-credentials /etc/letsencrypt/freenomdns.cfg \
  --certbot-dns-freenom:dns-freenom-propagation-seconds 600 \
  -d "*.argobay.ml" -d "argobay.ml"
```
DEV:
```bash
# @rikka
certbot certonly -a certbot-dns-freenom:dns-freenom \
  --certbot-dns-freenom:dns-freenom-credentials /etc/letsencrypt/freenomdns.cfg \
  --certbot-dns-freenom:dns-freenom-propagation-seconds 600 \
  -d "*.dev-argobay.ml" -d "dev-argobay.ml"
```


## Add disk checklist
- `fdisk`
- `mkfs.ext4 /dev/sdaX` for /var
- `mkfs.ext4 /dev/sdaY` for /mnt/data
- `mkdir -p /mnt/data`
- `mount /dev/sdaY /mnt/data`
- `lsblk -o NAME,UUID`
- add to /etc/fstab automount:
```ini
# SSD SMARTBUY 128 GiB
UUID=6fb42088-c559-4d1c-b4b6-b9246cf58312 /var ext4 defaults,auto,noatime,discard,rw,nofail 0 2
UUID=11e9a37a-4816-468f-84dc-5baee53f53f5 /mnt/data ext4 defaults,auto,noatime,discard,rw,nofail 0 2
```


## Move /var to another partion
```bash
mkdir -p /mnt/var
mkfs.ext4 /dev/sdaX
mount /dev/sdaX /mnt/var

lsblk -o NAME,UUID
nano /etc/fstab
# Add record to /etc/fstab
# Stop high-iops services

rsync -aqxP /var/* /mnt/var
umount /mnt/var

reboot
```


## Delete all old logs
```
find /var/log/ -name "*.gz" -type f -delete
```


## Enable wi-fi on RPi
comment line `dtoverlay=disable-wifi` in /boot/config.txt


## Install tensorflow==1.15.3 on RPi
```bash
pip uninstall tensorflow
pip3 uninstall tensorflow
apt install libhdf5-dev libc-ares-dev libeigen3-dev libatlas-base-dev libatlas3-base
pip3 install h5py==2.10.0
wget https://github.com/Qengineering/Tensorflow-Raspberry-Pi/raw/master/tensorflow-1.15.2-cp37-cp37m-linux_armv7l.whl
pip3 install tensorflow-1.15.2-cp37-cp37m-linux_armv7l.whl
```


## Start gitlab-runner manually
Go to `gitlab_runner_install_dir` and run docker-compose, for example:
```bash
cd /mnt/data/runners/arm-runner/
docker-compose up -d
```


## Create htpasswd file manually
```bash
htpasswd -c filename admin
```


## MDWiki external libs replace
```html
<!-- START extlib/js/highlight-7.3.pack.min.js -->
<link rel="stylesheet"
      href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.2.0/styles/default.min.css">
<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.2.0/highlight.min.js"></script>
<!-- END extlib/js/highlight-7.3.pack.min.js -->
```


## Setup Raspberry Pi without monitor
At root of boot sd-card:
```bash
# Enable ssh - create empty "ssh" file
touch ssh

# For WiFi setup:
cat > wpa_supplicant.conf <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=RU

network={
        ssid="${WIFI_SSID}"
        psk="${WIFI_PASS}"
}
EOF
```
