{% from "uwsgi/map.jinja" import uwsgi with context %}
{% set uwsgi_profile = salt.pillar.get('uwsgi_profile') %}

include:
  - .service

prepare_installation_of_pip_executable:
  pkg.installed:
    - pkgs: {{ uwsgi.pkgs }}
    - reload_modules: True

install_global_pip_executable:
  cmd.run:
    - name: |
        curl -L "https://bootstrap.pypa.io/get-pip.py" > get_pip.py
        sudo python get_pip.py
        rm get_pip.py
    - reload_modules: True
    - unless: which pip
    - reload_modules: True
    - require:
        - pkg: prepare_installation_of_pip_executable

install_uwsgi:
  pip.installed:
    - name: uwsgi
    - require_in:
        - service: uwsgi_service_running
    - require:
        - cmd: install_global_pip_executable
    {% if uwsgi_profile %}
    - env_vars:
        UWSGI_PROFILE: {{ uwsgi_profile }}
    {% endif %}

create_uwsgi_emperor_config:
  file.managed:
    - name: /etc/uwsgi/emperor.ini
    - source: salt://uwsgi/files/emperor.ini
    - makedirs: True

create_uwsgi_service_definition:
  file.managed:
    - name: /etc/systemd/system/uwsgi.service
    - source: salt://uwsgi/files/uwsgi.service
    - require_in:
        - service: uwsgi_service_running
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
        - file: create_uwsgi_service_definition

create_socket_directory_for_uwsgi:
  file.directory:
    - name: /var/run/uwsgi/
    - makedirs: True
    - user: www-data
    - group: www-data

create_log_directory_for_uwsgi:
  file.directory:
    - name: /var/log/uwsgi/apps
    - makedirs: True
    - user: www-data
    - group: www-data
