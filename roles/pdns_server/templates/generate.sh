#!/bin/sh

{% set zones = [] %}
{% for host in dnsmasq_hosts %}
{% for rec in host.rec %}
{% if rec.zone not in zones %}
{% set zones = zones.append(rec.zone) %}
/usr/bin/pdnsutil create-zone {{ rec.zone }} ns.argobay.ml
{% endif %}
{% endfor %}
{% endfor %}

{% for host in dnsmasq_hosts %}
{% for host_name in [ host.name ] + host.aliases | default([]) %}
{% for rec in host.rec %}
/usr/bin/pdnsutil add-record 168.192.in-addr.arpa {{ rec.ip.split('.')[3] }}.{{ rec.ip.split('.')[2] }} PTR {{ host_name }}.{{ rec.zone }}
/usr/bin/pdnsutil add-record {{ rec.zone }} {{ host_name }} A {{ rec.ip }}
{% if rec.haproxy | default('false') | bool %}
/usr/bin/pdnsutil add-record argobay.ml haproxy_{{ host_name }} A {{ rec.ip }}
/usr/bin/pdnsutil add-record i {{ host_name }} A {{ rec.ip }}
{% endif %}
{% endfor %}
{% endfor %}
{% endfor %}
