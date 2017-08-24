{% from "uwsgi/map.jinja" import uwsgi with context %}
{% set emperor_config = salt.pillar.get('uwsgi:emperor_config') %}

include:
  - .service
  - .install

{% if emperor_config %}
write_additional_configs_for_emperor:
  file.managed:
    - name: /etc/uwsgi/emperor_extra.ini
    - source: salt://uwsgi/templates/conf.ini.jinja
    - template: jinja
    - context:
        settings: {{ emperor_config }}
    - require:
        - file: create_uwsgi_emperor_config
    - onchanges_in:
        - service: uwsgi_service_running
{% endif %}

{% for app_name, app_config in salt.pillar.get('uwsgi:apps', {}).items() %}
manage_config_for_{{ app_name }}:
  file.managed:
    - name: /etc/uwsgi/vassals/{{ app_name }}.ini
    - source: salt://uwsgi/templates/conf.ini.jinja
    - template: jinja
    - context:
        settings: {{ app_config }}
    - makedirs: True
{% endfor %}
