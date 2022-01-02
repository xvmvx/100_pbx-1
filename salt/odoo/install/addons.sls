{%- from "odoo/map.jinja" import odoo with context -%}

addons-cloned:
  git.latest:
    - name: https://github.com/odoopbx/addons.git
    - branch: {{ odoo.version }}
    - depth: 1
    - fetch_tags: False
    - rev: {{ odoo.version }}
    - target: {{ odoo.path.addons }}

addons-pip-reqs:
  pip.installed:
    - upgrade: {{ odoo.upgrade }}
    - requirements: {{ odoo.path.addons }}/requirements.txt
    - bin_env: {{ odoo.path.venv }}
    - require:
      - addons-cloned
    - retry: True

asterisk-plus-init:
  cmd.run:
    - name: >
        {{ odoo.path.venv }}/bin/python {{ odoo.path.src }}/odoo-bin
        --config {{ odoo.path.conf }} --no-http --stop-after-init  -i asterisk_plus
    - require:
      - addons-pip-reqs
    - runas: {{ odoo.user }}
    - shell: /bin/bash

asterisk-plus-pip-upgrade:
  cmd.run:
    - name: pip3 install --upgrade pip
    - reload_modules: true
    - onfail:
      - pip: addons-pip-reqs
