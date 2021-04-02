## TODO list

### Main

- Extract docker to dedicated role
- Add basic_auth for prometheus, alertmanager, smarthome
- Add redis password auth
- Backup DBs from cron
- Backup Grafana data
- Prometheus remote write/read for long-term storage

### Backlog

- Suggest to use the nginx-lua-prometheus exporter
- Fix certbot systemd unit with /usr/local/bin
- Customize mdwiki
- Make jupyter-notebook role with the systemd unit
- Upgrade Redis to master-slave replication
- Add deb-package repo
- Add keepalived_exporter
- Remake dnsmasq_exporter

### Failed

- Suggest to use 1.x version of Prometheus - extremely outdated configuration

### Useful links

[jyputer unit](https://gist.github.com/whophil/5a2eab328d2f8c16bb31c9ceaf23164f)
[redis replication](https://rtfm.co.ua/redis-replikaciya-chast-2-master-slave-replikaciya-i-redis-sentinel/)
[systemd prometheus](https://medium.com/kartbites/process-level-monitoring-and-alerting-in-prometheus-915ed7508058)
[prometheus alert rules](https://awesome-prometheus-alerts.grep.to/rules.html)

### VS

https://github.com/inCaller/prometheus_bot vs current
