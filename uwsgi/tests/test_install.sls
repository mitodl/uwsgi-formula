{% from "uwsgi/map.jinja" import uwsgi with context %}

{% for pkg in uwsgi.pkgs %}
test_{{pkg}}_is_installed:
  testinfra.package:
    - name: {{ pkg }}
    - is_installed: True
{% endfor %}

test_uwsgi_emperor_running:
  testinfra.service:
    - name: {{ uwsgi.service }}
    - is_running: True
