{%- from "odoo/map.jinja" import odoo with context -%}

#p.get_dir path=salt://addons/asterisk_plus dest={{ odoo.path }}/addons_plus
odoo-addons-get:
  file.recurse:
    - name: {{ odoo.prefix }}/odoogit@gitlab.com:odoopbx/addons.git
    - branch: {{ odoo.version }}
    - depth: 1
    - fetch_tags: False
    - rev: {{ odoo.version }}
    - target: {{ odoo.path }}/addons/{{ odoo.version }}
    - identity: salt://files/id_rsa
    - require:
      - odoo-addons-dirs
    - force_checkout: True
    - force_clone: True
    - force_reset: True


odoo-addons-reqs:
  pip.installed:
    - upgrade: {{ odoo.upgrade }}
    - requirements: {{ odoo.path }}/addons_plus/asterisk_plus/requirements.txt
    - bin_env: {{ odoo.path }}/venv/odoo{{ odoo.major_version }}
    - onlyif:
      - stat  {{ odoo.path }}/addons_plus/asterisk_plus/requirements.txt
    - retry: True

odoo-addons-init:
  cmd.run:
    - name: >
        {{ odoo.path }}/venv/odoo{{ odoo.major_version }}/bin/python {{ odoo.path }}/src/odoo-{{ odoo.version }}/odoo-bin 
        --config /etc/odoo/odoo{{ odoo.major_version }}.conf --no-http --stop-after-init  -i asterisk_plus
    - require:
      - odoo-addons-plus-reqs
    - runas: {{ odoo.user }}
    - shell: /bin/bash
