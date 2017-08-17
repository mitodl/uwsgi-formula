{% from "uwsgi/map.jinja" import uwsgi with context %}

include:
  - .service

uwsgi:
  pkg.installed:
    - pkgs: {{ uwsgi.pkgs }}
    - require_in:
        - service: uwsgi_service_running
