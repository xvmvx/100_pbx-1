{%- from "odoo/map.jinja" import odoo with context -%}

odoo-addons-plus-reqs:
  pip.installed:
    - upgrade: {{ odoo.upgrade }}
    - requirements: /srv/odoo/addons_plus/asterisk_plus/requirements.txt
    - bin_env: /srv/odoo/venv/odoo{{ odoo.major_version }}
    - onlyif:
      - stat  /srv/odoo/addons_plus/asterisk_plus/requirements.txt
    - retry: True

odoo-addons-init:
  cmd.run:
    - name: >
        /srv/odoo/venv/odoo{{ odoo.major_version }}/bin/python /srv/odoo/src/odoo-{{ odoo.version }}/odoo-bin 
        --config /etc/odoo/odoo{{ odoo.major_version }}.conf --no-http --stop-after-init  -i asterisk_plus
    - require:
      - odoo-addons-plus-reqs
    - runas: {{ odoo.user }}
    - shell: /bin/bash
