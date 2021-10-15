{%- from "odoo/map.jinja" import odoo with context -%}

{%- if grains.get('init', 'unknown') in ['systemd',] %}
odoo-service-start:
  service.running:
    - name: odoo{{ odoo.major_version }}
    - enable: true
    - onlyif:
        - runlevel
    - require:
      - cmd: odoo-addons-init
{%- else %}
odoo-run:
  cmd.run:
    - name: >
        sudo -u odoo /srv/odoo/venv/odoo{{ odoo.major_version }}/bin/python
        /srv/odoo/src/odoo-{{ odoo.version }}/odoo-bin
        -c /etc/odoo/odoo{{ odoo.major_version }}.conf
    - shell: /bin/bash
    - bg: True
    - hide_output: True
    # ToDo
    #- unless:
    #    - pidof odoo
{%- endif %}
