{% from "uwsgi/map.jinja" import uwsgi with context %}

include:
  - .service

{% for app_name, app_config in salt.pillar.get('uwsgi:apps', {}).items() %}
manage_config_for_{{ app_name }}:
  file.managed:
    - name: /etc/uwsgi/vassals/{{ app_name }}.yml
    - contents: |
        {{ app_config|yaml(False)|indent(8) }}
{% endfor %}
