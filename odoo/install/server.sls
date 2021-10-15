{%- from "odoo/map.jinja" import odoo with context -%}

odoo-pkg-reqs:
  pkg.installed:
    - pkgs:
      - git
      - libxml2-dev
      - libxslt1-dev
      - libjpeg-dev
      - libldap2-dev
      - libsasl2-dev
      - libpq-dev
      - python3-dev
      - sudo

virtualenv-installed:
  pip.installed:
    - name: virtualenv

virtualenv-init:
  virtualenv.managed:
    - name: /srv/odoo/venv/odoo{{ odoo.major_version }}
    - python: python3

odoo-pip-upgraded:
  cmd.run:
    - name: /srv/odoo/venv/odoo{{ odoo.major_version }}/bin/pip3 install --upgrade pip
    - reload_modules: true
    - require:
      - virtualenv-init
    - onfail:
      - odoo-pip-reqs

odoo-group:
  group.present:
    - name: {{ odoo.user }}

odoo-user:
  user.present:
    - name: {{ odoo.user }}
    - groups:
      - {{ odoo.user }}
    - shell: /bin/bash

odoo-src-dir:
  file.directory:
    - name: /srv/odoo/src/
    - makedirs: True

odoo-filestore-dir:
  file.directory:
    - name: /srv/odoo/data/filestore
    - makedirs: True
    - user: {{ odoo.user }}
    - group: root
    - dir_mode: 750

odoo-addons-dir:
  file.directory:
    - name: /srv/odoo/addons/{{ odoo.version }}
    - makedirs: True
    - user: root
    - group: {{ odoo.user }}
    - dir_mode: 750

odoo-etc-dir:
  file.directory:
    - name: /etc/odoo
    - group: odoo
    - dir_mode: 750

odoo-cloned:
  git.latest:
    - name: https://github.com/odoo/odoo.git
    - branch: {{ odoo.version }}
    - depth: 1
    - fetch_tags: False
    - rev: {{ odoo.version }}
    - target: /srv/odoo/src/odoo-{{ odoo.version }}
    - require:
      - odoo-pkg-reqs

odoo-pip-reqs:
  pip.installed:
    - upgrade: {{ odoo.upgrade }}
    - requirements: /srv/odoo/src/odoo-{{ odoo.version }}/requirements.txt
    - bin_env: /srv/odoo/venv/odoo{{ odoo.major_version }}
    - require:
      - odoo-cloned
    - retry: True

odoo-configs:
  file.managed:
    - names:
      - /etc/odoo/odoo{{ odoo.major_version }}.conf:
        - source: salt://odoo/templates/odoo.conf
        - group: {{ odoo.user }}
        - mode: 640
      - /etc/systemd/system/odoo{{ odoo.major_version }}.service:
        - source: salt://odoo/templates/odoo.service
      - /etc/profile.d/odoo.sh:
        - contents: >
            alias odoo="sudo -u odoo /srv/odoo/venv/odoo{{ odoo.major_version }}/bin/python
            /srv/odoo/src/odoo-{{ odoo.version }}/odoo-bin
            -c /etc/odoo/odoo{{ odoo.major_version }}.conf"
    - user: root
    - mode: 644
    - template: jinja
    - context: {{ odoo }}
    - replace: True
    - backup: minion

odoo-service-stop:
  service.dead:
    - name: odoo{{ odoo.major_version }}
    - onlyif:
      - runlevel
    - require:
      - file: odoo-configs

odoo-dbuser:
  postgres_user.present:
    - name: {{ odoo.user }}
    - createdb: True
    - encrypted: True
    - db_user: postgres
    - require:
      - odoo-pip-reqs

odoo-init:
  cmd.run:
    - name: >
        /srv/odoo/venv/odoo{{ odoo.major_version }}/bin/python /srv/odoo/src/odoo-{{ odoo.version }}/odoo-bin 
        --config /etc/odoo/odoo{{ odoo.major_version }}.conf --no-http --stop-after-init  -i base
    - runas: {{ odoo.user }}
    - shell: /bin/bash
    - unless: >
        echo "env['res.users']" | 
        /srv/odoo/venv/odoo{{ odoo.major_version }}/bin/python /srv/odoo/src/odoo-{{ odoo.version }}/odoo-bin shell
        --config /etc/odoo/odoo{{ odoo.major_version }}.conf --no-http
    - require:
      - odoo-dbuser
