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
    - name: {{ odoo.path.venv }}
    - python: python3

odoo-pip-upgraded:
  cmd.run:
    - name: {{ odoo.path.venv }}/bin/pip3 install --upgrade pip
    - reload_modules: true
    - require:
      - virtualenv-init
    - onfail:
      - odoo-pip-reqs

odoo-user:
  user.present:
    - name: {{ odoo.user }}
    - usergroup: True
    - shell: /bin/bash

odoo-make-dirs:
  file.directory:
    - names:
      - {{ odoo.path.data }}/filestore:
        - user: {{ odoo.user }}
      - {{ odoo.path.addons }}:
        - group: {{ odoo.user }}
    - makedirs: True
    - dir_mode: 750

odoo-cloned:
  git.latest:
    - name: https://github.com/odoo/odoo.git
    - branch: {{ odoo.version }}
    - depth: 1
    - fetch_tags: False
    - rev: {{ odoo.version }}
    - target: {{ odoo.path.src }}
    - require:
      - odoo-pkg-reqs

odoo-pip-reqs:
  pip.installed:
    - upgrade: {{ odoo.upgrade }}
    - requirements: {{ odoo.path.src }}/requirements.txt
    - bin_env: {{ odoo.path.venv }}
    - require:
      - odoo-cloned
    - retry: True

odoo-configs:
  file.managed:
    - names:
      - {{ odoo.path.conf }}:
        - source: salt://odoo/templates/odoo.conf
        - group: {{ odoo.user }}
        - mode: 640
        - makedirs: True
      - /etc/systemd/system/odoo{{ odoo.major_version }}.service:
        - source: salt://odoo/templates/odoo.service
      - /etc/profile.d/odoo.sh:
        - contents: >
            alias odoo=\'sudo -u odoo {{ odoo.path.venv }}/bin/python
            {{ odoo.path.src }}/odoo-bin -c {{ odoo.path.conf }}\'
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
        {{ odoo.path.venv }}/bin/python {{ odoo.path.src }}/odoo-bin
        --config {{ odoo.path.conf }} --no-http --stop-after-init  -i base
    - runas: {{ odoo.user }}
    - shell: /bin/bash
    - unless: >
        echo "env['res.users']" | 
        {{ odoo.path.venv }}/bin/python {{ odoo.path.src }}/odoo-bin shell
        --config {{ odoo.path.conf }} --no-http
    - require:
      - odoo-dbuser
