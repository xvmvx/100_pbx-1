{%- from "odoo/map.jinja" import odoo with context -%}

odoo-addons-dirs:
  file.directory:
    - names:
        - /srv/odoo/addons/{{ odoo.version }}
    - follow_symlinks: False
    - allow_symlink: False
    - force: False
    - makedirs: True

odoo-addons-cloned:
  git.latest:
    - name: git@gitlab.com:odoopbx/addons.git
    - branch: {{ odoo.version }}
    - depth: 1
    - fetch_tags: False
    - rev: {{ odoo.version }}
    - target: /srv/odoo/addons/{{ odoo.version }}
    - identity: salt://files/id_rsa
    - require:
      - odoo-addons-dirs
    - force_checkout: True
    - force_clone: True
    - force_reset: True

oodoo-addons-reqs:
  pip.installed:
    - upgrade: {{ odoo.upgrade }}
    - requirements: /srv/odoo/addons/{{ odoo.version }}/requirements.txt
    - bin_env: /srv/odoo/venv/odoo{{ odoo.major_version }}
    - require:
      - odoo-addons-cloned
    - retry: True

odoo-addons-init:
  cmd.run:
    - name: >
        /srv/odoo/venv/odoo{{ odoo.major_version }}/bin/python /srv/odoo/src/odoo-{{ odoo.version }}/odoo-bin 
        --config /etc/odoo/odoo{{ odoo.major_version }}.conf --no-http --stop-after-init  -i asterisk_base_sip
    - require:
      - odoo-addons-reqs
    - runas: {{ odoo.user }}
    - shell: /bin/bash
