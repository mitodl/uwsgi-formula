{% from "uwsgi/map.jinja" import uwsgi with context %}

include:
  - .install
  - .service

uwsgi-config:
  file.managed:
    - name: {{ uwsgi.conf_file }}
    - source: salt://uwsgi/templates/conf.jinja
    - template: jinja
    - watch_in:
      - service: uwsgi_service_running
    - require:
      - pkg: uwsgi
