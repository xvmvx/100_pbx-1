{%- from "odoo/map.jinja" import odoo with context -%}

{%- if grains.get('init', 'unknown') in ['systemd',] %}
odoo-service-start:
  service.running:
    - name: odoo{{ odoo.major_version }}
    - enable: true
    - onlyif:
        - runlevel
{%- else %}
odoo-run:
  cmd.run:
    - name: >
        sudo -u odoo {{ odoo.path.venv }}/bin/python {{ odoo.path.src }}/odoo-bin
        -c {{ odoo.path.conf }}
    - shell: /bin/bash
    - bg: True
    - hide_output: True
    # ToDo
    #- unless:
    #    - pidof odoo
{%- endif %}
