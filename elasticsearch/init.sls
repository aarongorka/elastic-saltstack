elasticsearch:
  pkg.installed: []
  service.running:
    - enable: True
    - restart: True

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://elasticsearch/files/elasticsearch.yml
    - template: jinja
    - watch_in:
      - service: elasticsearch

/etc/sysconfig/elasticsearch:
  file.managed:
    - source: salt://elasticsearch/files/elasticsearch
    - template: jinja
    - watch_in:
      - service: elasticsearch
    
{% if grains['os_family'] == 'RedHat' %}
/etc/yum.repos.d/elasticsearch.repo:
  file.managed:
    - source: salt://elasticsearch/files/elasticsearch.repo
    - require_in:
      - pkg: elasticsearch
{% endif %}

/etc/elasticsearch/jvm.options:
  file.managed:
    - source: salt://elasticsearch/files/jvm.options
    - template: jinja
    - watch_in:
      - service: elasticsearch

vm.swappiness:
  sysctl.present:
    - value: 1

/etc/systemd/system/elasticsearch.service.d/mlockall.conf:
  file.managed:
    - source: salt://elasticsearch/files/mlockall.conf
    - template: jinja
    - makedirs: True
    - require_in:
      - service: elasticsearch

/etc/security/limits.d/30-elasticsearch.conf:
  file.managed:
    - source: salt://elasticsearch/files/30-elasticsearch.conf
    - template: jinja
    - require_in:
      - service: elasticsearch

systemctl daemon-reload:
  cmd.wait:
    - watch_in:
      - file: /etc/systemd/system/elasticsearch.service.d/mlockall.conf
