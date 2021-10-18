{%- from "odoo/map.jinja" import odoo with context -%}

#p.get_dir path=salt://addons/asterisk_plus dest={{ odoo.path }}/addons_plus
asterisk-plus-get:
  file.recurse:
    - name: {{ odoo.path.addons }}/asterisk_plus
    - source: salt://addons/asterisk_plus
    - saltenv: "{{ odoo.version }}"

asterisk-plus-reqs:
  pip.installed:
    - upgrade: {{ odoo.upgrade }}
    - requirements: {{ odoo.path.addons }}/asterisk_plus/requirements.txt
    - bin_env: {{ odoo.path.venv }}
    - retry: True

asterisk-plus-init:
  cmd.run:
    - name: >
        {{ odoo.path.venv }}/bin/python {{ odoo.path.src }}/odoo-bin
        --config {{ odoo.path.conf }} --no-http --stop-after-init  -i asterisk_plus
    - require:
      - asterisk-plus-reqs
    - runas: {{ odoo.user }}
    - shell: /bin/bash

asterisk-plus-pip-upgrade:
  cmd.run:
    - name: pip3 install --upgrade pip
    - reload_modules: true
    - onfail:
      - pip: asterisk-plus-reqs
