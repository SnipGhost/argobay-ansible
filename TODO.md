## TODO list

### Main
- Fix Golang install in common role
- Fix dnsmasq main record generation
- VictoriaMetrics HA with Zelda
- Fix Prometheus*Slow alerts for Victoria Metrics
- Add deb-package repo & pipelines
- Add redis password auth
- Install OIDC-Provider
- Install K8S
- HTTP-cache nginx + keepalive connections
- Ceph secure iptables (static ports for osd-s)

### Backlog
- Extract vmagent & vmalert from victoria_metrics role
- Fix certbot systemd unit with /usr/local/bin
- Make jupyter-notebook role with the systemd unit
- Upgrade Redis to master-slave replication

### Failed
- Suggest to use 1.x version of Prometheus - extremely outdated configuration

### Rejected
- Suggest to use the nginx-lua-prometheus exporter - Additional workload with minimal benefit.
- Add keepalived_exporter - It is enough to control the presence of the process.
- Remake dnsmasq_exporter - It was decided to move to a more powerful DNS server in the future.

### Useful links
[jyputer unit](https://gist.github.com/whophil/5a2eab328d2f8c16bb31c9ceaf23164f)
[redis replication](https://rtfm.co.ua/redis-replikaciya-chast-2-master-slave-replikaciya-i-redis-sentinel/)
[systemd prometheus](https://medium.com/kartbites/process-level-monitoring-and-alerting-in-prometheus-915ed7508058)
[prometheus alert rules](https://awesome-prometheus-alerts.grep.to/rules.html)

### VS
https://github.com/inCaller/prometheus_bot vs current
