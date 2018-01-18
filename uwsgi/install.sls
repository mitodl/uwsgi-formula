{% from "uwsgi/map.jinja" import uwsgi with context %}
{% set uwsgi_build_env = salt.pillar.get('uwsgi:build_env', {}) %}

include:
  - .service

install_os_package_dependencies:
  pkg.installed:
    - pkgs: {{ uwsgi.pkgs }}
    - reload_modules: True

install_global_pip_executable:
  cmd.run:
    - name: |
        curl -L "https://bootstrap.pypa.io/get-pip.py" > get_pip.py
        sudo python3 get_pip.py
        rm get_pip.py
    - reload_modules: True
    - creates: {{ uwsgi.pip_path }}
    - reload_modules: True
    - require:
        - pkg: install_os_package_dependencies

install_uwsgi:
  pip.installed:
    - name: uwsgi
    - bin_env: {{ uwsgi.pip_path }}
    - require_in:
        - service: uwsgi_service_running
    - require:
        - cmd: install_global_pip_executable
    {% if uwsgi_build_env -%}
    - env_vars:
        {%- for var, value in uwsgi_build_env.items() %}
        {{ var }}: {{ value }}
        {% endfor -%}
    {%- endif %}

create_uwsgi_emperor_config:
  file.managed:
    - name: /etc/uwsgi/emperor.ini
    - source: salt://uwsgi/files/emperor.ini
    - makedirs: True

create_uwsgi_service_user:
  user.present:
    - name: {{ uwsgi.user }}
    - system: True

create_uwsgi_service_definition:
  file.managed:
    - name: /etc/systemd/system/{{ uwsgi.service }}.service
    - source: salt://uwsgi/templates/uwsgi.service
    - template: jinja
    - context:
        uwsgi_path: {{ uwsgi.uwsgi_path }}
    - require_in:
        - service: uwsgi_service_running
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
        - file: create_uwsgi_service_definition

create_log_directory_for_uwsgi:
  file.directory:
    - name: /var/log/uwsgi/apps
    - makedirs: True
    - user: {{ uwsgi.user }}
    - group: {{ uwsgi.user }}
