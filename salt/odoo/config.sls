{%- from "odoo/map.jinja" import odoo with context -%}

odoo-dbuser:
  postgres_user.present:
    - name: {{ odoo.user }}
    - createdb: True
    - encrypted: True
    - db_user: postgres

odoo-env:
  environ.setenv:
    - name: ODOO_RC
    - value: {{ odoo.conf_path }}

odoo-init:
  cmd.run:
    - name: {{ odoo.src_path }}/odoo-bin --no-http --stop-after-init  -i base
    - runas: {{ odoo.user }}
    - shell: /bin/bash
    - unless: >
        echo "env['res.users']" | 
        {{ odoo.src_path }}/odoo-bin shell --no-http
    - require:
      - odoo-dbuser

asterisk-plus-init:
  cmd.run:
    - name: >
        {{ odoo.src_path }}/odoo-bin --no-http --stop-after-init  -i asterisk_plus
    - runas: {{ odoo.user }}
    - shell: /bin/bash
    - require:
      - odoo-init
