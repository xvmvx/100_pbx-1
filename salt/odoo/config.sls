{%- from "odoo/map.jinja" import odoo with context -%}

odoo-dbuser:
  postgres_user.present:
    - name: {{ odoo.user }}
    - createdb: True
    - encrypted: True
    - db_user: postgres

odoo-init-base:
  cmd.run:
    - name: >
        {{ odoo.src_path }}/odoo-bin -c {{ odoo.conf_path }} -d {{ salt['environ.get']('ODOO_DB') }}
        --no-http --stop-after-init  -i base
    - runas: {{ odoo.user }}
    - shell: /bin/bash
    - unless: >
        echo "env['res.users']" |
        {{ odoo.src_path }}/odoo-bin shell --no-http
    - require:
      - odoo-dbuser

odoo-init-asterisk_plus:
  cmd.run:
    - name: >
        {{ odoo.src_path }}/odoo-bin -c {{ odoo.conf_path }} -d {{ salt['environ.get']('ODOO_DB') }}
        --no-http --stop-after-init  -i asterisk_plus
    - runas: {{ odoo.user }}
    - shell: /bin/bash
    - require:
      - odoo-init-base
