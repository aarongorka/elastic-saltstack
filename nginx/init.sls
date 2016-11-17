{% from "nginx/map.jinja" import nginx with context %}

{{ nginx.name }}:
  pkg.installed: []
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: {{ nginx.name }}
    
openssl dhparam -out /etc/pki/tls/private/dhparams.pem 4096:
  cmd.wait:
    - watch:
      - pkg: {{ nginx.name }}
    - watch_in:
      - service: {{ nginx.name }}

{% if grains['os_family'] == 'RedHat' %}
nginx_firewalld_cmd_http:
  cmd.run:
    - name: firewall-cmd --permanent --add-service=http && firewall-cmd --reload
    - unless: firewall-cmd --list-all | grep http

nginx_firewalld_cmd_https:
  cmd.run:
    - name: firewall-cmd --permanent --add-service=https && firewall-cmd --reload
    - unless: firewall-cmd --list-all | grep https

/usr/share/nginx/html/404.html:
  file.managed:
    - contents: ''

/usr/share/nginx/html/50x.html:
  file.managed:
    - contents: ''

/usr/share/nginx/html/index.html:
  file.managed:
    - contents: ''

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://nginx/files/nginx.conf
    - template: jinja
    - watch_in:
      - service: {{ nginx.name }}
{% endif %}
