{% from "uwsgi/map.jinja" import uwsgi with context %}

uwsgi_service_running:
  service.running:
    - name: {{ uwsgi.service }}
    - enable: True
