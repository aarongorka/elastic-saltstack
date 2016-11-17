include:
  - nginx

kibana:
  pkg.installed: []
  service.running:
    - enable: True
    - reload: True

/etc/nginx/conf.d/kibana.conf:
  file.managed:
    - source: salt://kibana/files/kibana.conf
    - template: jinja
    - watch_in:
      - service: nginx
    - defaults:
        domains: {{ pillar['kibana_fqdn'] }}

kibana_httpd_bool:
  cmd.run:
    - name: setsebool -P httpd_can_network_connect 1
    - unless: getsebool httpd_can_network_connect | grep -e '--> on'

{% if grains['os_family'] == 'RedHat' %}
/etc/yum.repos.d/kibana.repo:
  file.managed:
    - source: salt://kibana/files/kibana.repo
    - require_in:
      - pkg: kibana
{% endif %}

