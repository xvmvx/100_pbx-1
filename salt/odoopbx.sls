{% if grains.os_family == "Debian" %}
include:
  - agent
  - asterisk
  - postgres
  - odoo
  - odoo.config
  - nginx
{% else %}
not-yet-supported:
  test.show_notification:
    - text: Sorry, {{ grains.os_family }} is not supported yet
{% endif %}

odoopbx-configure:
  file.managed:
    - name: /etc/salt/minion_local.conf
    - contents: |
        ami_host: 127.0.0.1
        odoo_host: 127.0.0.1
  {%- if "virtual_subtype" not in grains %}
  host.present:
    - name: agent
    - ip: 127.0.0.1
  {%- endif %}

{%- if grains.get('init') in ['systemd',] %}
odoopbx-run-services:
  service.running:
    - names:
      - odoo
      - salt-master
      - salt-api
      - salt-minion
{%- endif %}
