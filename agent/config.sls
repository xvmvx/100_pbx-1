{% from "agent/map.jinja" import agent with context %}

agent-get-config:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://agent/files/etc/minion
    - template: jinja
    - context: {{ agent }}

agent-get-files:
  file.recurse:
    - names:
      - /etc/salt:
        - source: salt://agent/files/etc
        - exclude_pat: minion
      - /var/cache/salt/minion/extmods:
        - source: salt://agent/files/extensions

agent-autosign-config:
  file.managed:
    - name: /etc/salt/autosign/id
    - contents: {{ grains.id }}
    - makedirs: True

agent-api-auth:
  file.managed:
    - name: /etc/salt/auth
    - contents: "odoo|0a8f125a3f41f36c0507203a63cde9ad"
