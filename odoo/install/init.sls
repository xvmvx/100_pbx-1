{%- from "odoo/map.jinja" import odoo with context -%}

include:
  - .server
  - .addons_plus

odoo-pip-upgrade:
  cmd.run:
    - name: pip3 install --upgrade pip
    - reload_modules: true
    - onfail:
      - pip: odoo-addons-plus-reqs
