{% if grains.os_family == "Debian" %}
include:
  {%- if not salt['environ.get']('GITLAB_CI') == 'true' %}
  - asterisk
  {%- endif %}
  - postgres
  - nginx
  - odoo
  - agent
{% else %}
not-yet-supported:
  test.show_notification:
    - text: Sorry, {{ grains.os_family }} is not supported yet
{% endif %}
