{% from "uwsgi/map.jinja" import uwsgi with context %}
{% set emperor_config = salt.pillar.get('uwsgi:emperor_config') %}

{# Application configuration defaults are based on recommendations in this
   article:
   https://www.techatbloomberg.com/blog/configuring-uwsgi-production-deployment/
#}
{% set app_config_defaults = {
       'strict': 'true',
       'enable-threads': 'true',
       'vacuum': 'true',
       'single-interpreter': 'true',
       'die-on-term': 'true',
       'need-app': 'true',
       'disable-logging': 'true',
       'log-4xx': 'true',
       'log-5xx': 'true',
       'max-requests': '1000',
       'max-worker-lifetime': '3600',
       'processes': '2',
       'reload-on-rss': '200',
       'worker-reload-mercy': '60',
       'harakiri': '60',
       'py-callos-afterfork': 'true',
       'buffer-size': '65535',
       'post-buffering': '65535',
       'auto-procname': 'true'
   }
%}
{% if not emperor_config %}
{% do app_config_defaults.update({'master': 'true'}) %}
{% endif %}

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

{# This feels hacky, but I don't see a better way (like pillar.get() with
   "merge"). uwsgi:apps has an app name property that varies.
#}
{% for app_name, app_config_overrides in salt.pillar.get('uwsgi:apps', {}).items() %}
{% set app_config = app_config_defaults.copy() %}
{% app_config.update(app_config_overrides) %}
manage_config_for_{{ app_name }}:
  file.managed:
    - name: /etc/uwsgi/vassals/{{ app_name }}.ini
    - source: salt://uwsgi/templates/conf.ini.jinja
    - template: jinja
    - context:
        settings: {{ app_config|yaml }}
    - makedirs: True
{% endfor %}
