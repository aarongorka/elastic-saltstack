logstash:
  pkg.installed: []
  service.running:
    - enable: True
    - restart: True
    
{% if grains['os_family'] == 'RedHat' %}
/etc/yum.repos.d/logstash.repo:
  file.managed:
    - source: salt://logstash/files/logstash.repo
    - template: jinja
    - watch_in:
      - pkg: logstash
{% endif %}

/etc/ld.so.conf.d/logstash.conf:
  file.managed:
    - source: salt://logstash/files/logstash.conf
    - template: jinja
    - require_in:
      - service: logstash

ldconfig_logstash:
  cmd.wait:
    - name: ldconfig
    - watch:
      - file: /etc/ld.so.conf.d/logstash.conf

# Allow a non-privileged process to listen on a port <1024
logstash_setcap:
  cmd.run:
    - name: setcap 'cap_net_bind_service=+ep' $(readlink -f $(which java))
    - unless: getcap $(readlink -f $(which java)) | grep 'cap_net_bind_service\+ep'
    - watch:
      - pkg: logstash
    - require_in:
      - service: logstash

{% if grains['os_family'] == 'RedHat' %}
logstash-repo-key:
  cmd.run:
    - name:  rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
    - unless: rpm -qi gpg-pubkey-d88e42b4-52371eca
    - require_in:
      - pkg: logstash

beats_firewalld_cmd:
  cmd.run:
    - name: firewall-cmd --permanent --add-port=5044/tcp && firewall-cmd --reload
    - unless: firewall-cmd --list-all | grep 5044
{% endif %}

