uwsgi_service_running:
  service:
    - running
    - name: {{ uwsgi.service }}
    - enable: True
