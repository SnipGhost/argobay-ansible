# Ceph operations guide

## Create ceph logical volume
```bash
pvcreate /dev/sda1
vgcreate cephvg /dev/sda1
lvcreate --name cephlv -l 100%FREE cephvg
```

## Create crush tree
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
ceph osd crush add-bucket rapunzel host
ceph osd crush move asuna datacenter=prod-home
ceph osd crush move ichika datacenter=prod-home
ceph osd crush move zelda datacenter=prod-home
ceph osd crush move itsuki datacenter=prod-home
ceph osd crush move rapunzel datacenter=prod-home
ceph osd crush rule create-replicated prod-rule prod-root osd ssd

ceph osd crush set osd.0 0.060 root=prod-root datacenter=prod-home host=asuna
ceph osd crush set osd.1 0.060 root=prod-root datacenter=prod-home host=itsuki
ceph osd crush set osd.2 0.120 root=prod-root datacenter=prod-home host=rapunzel
ceph osd crush set osd.3 0.060 root=prod-root datacenter=prod-home host=zelda

ceph osd crush set osd.X 0.060 root=prod-root datacenter=prod-home host=ichika
```

## Create CephFS
```bash
ceph osd pool create cephfs_data 64
ceph osd pool create cephfs_metadata 16
ceph osd pool set cephfs_data crush_rule prod-rule
ceph osd pool set cephfs_metadata crush_rule prod-rule
ceph fs new cephfs cephfs_metadata cephfs_data
ceph fs ls
```

## Mount CephFS
Available only with module ceph in /lib/modules/
Core: 5.10.27-v7l-ceph+

```bash
mount -t ceph zelda:6789,asuna:6789,rapunzel:6789:/ /mnt/cephfs -o name=admin,secretfile=/etc/ceph/admin.secret,noatime
```

## Enable Ceph monitoring
```bash
ceph mgr module enable prometheus
```

## Remove OSD
```bash
ceph osd out ${id}
systemctl stop ceph-osd@${id}
ceph osd purge ${id} --yes-i-really-mean-it
```

## Add MON
Just run ceph-mon role without any variables

## Add OSD
Just run ceph-osd role with `manage_disks=yes`
