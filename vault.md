# Example of vault secrets variables

Playbooks require secret variables:
```yaml
##########################################################################################
# Keepalived VIPs
service_vip_password: example
public_vip_password: example
private_vip_password: example
monitoring_vip_password: example
research_vip_password: example
dev_public_vip_password: example
dev_private_vip_password: example
rgw_lb_vip_password: example
consul_vip_password: example
##########################################################################################
ansible_become_pass: example
##########################################################################################
# Linux user's passwords
passwords:
  root: example
  ansible: example
##########################################################################################
# Default SMTP options
smtp_user: user@example.com
smtp_pass: example
smtp_host: example.com:465
smtp_from: user@example.com
smtp_name: Name
##########################################################################################
# WiFi options
ap_ssid: ssid_example
ap_code: RU
ap_pass: example
##########################################################################################
# Alertmanager bot
alertmanager_bot_telegram_token: example
##########################################################################################
# Payment exporter
payment_exporter_user: example
payment_exporter_pass: example
##########################################################################################
# rsyncd
rsync_certs_user: example
rsync_certs_pass: example
##########################################################################################
# MariaDB user's passwords
mariadb_sst_pass: example
mariadb_clustercheck:
  user: example
  pass: example
##########################################################################################
# PostgreSQL
postgresql_dbs:
  - name: db_example
    user: example
    pass: example
postgresql_repl_pass: example
##########################################################################################
# HAProxy
haproxy_stat_user: example
haproxy_stat_pass: example
##########################################################################################
# Marusya skill API
krionard_db_name: krionardtech
krionard_db_user: example
krionard_db_pass: example
##########################################################################################
# SmartHome API
dacrover_db_name: dacrover
dacrover_db_user: example
dacrover_db_pass: example
dacrover_basic_user: example
dacrover_basic_pass: example
##########################################################################################
# Razumator
razumator_db_name: razumator
razumator_db_user: example
razumator_db_pass: example
##########################################################################################
# GitLab Runner
gitlab_runner_reg_token: example
##########################################################################################
# Admin htpasswd password (only base64 encoding)
htpasswd: $apr1$ZbHHKQvL$0z/SXRbPbfohsC6a3vrJ8. # decoded: test
##########################################################################################
```

Example to create vault file:
```bash
ansible-vault encrypt groupvars/all/secret.yml
```

Example to edit vault file:
```bash
ansible-vault edit groupvars/all/secret.yml
```

Example to show vault file:
```bash
ansible-vault view groupvars/all/secret.yml
```
