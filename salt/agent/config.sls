{% from "agent/map.jinja" import agent with context %}

generate-minion-id:
  cmd.run:
    - name: uuidgen > /etc/salt/minion_id
    - unless: bash -s [ "`cat /etc/salt/minion_id | wc -c`" = "37" ] # UUID string?

agent-get-config:
  file.managed:
    - names:
      - /etc/salt/minion:
        - source: salt://agent/files/etc/minion
      - /etc/salt/master:
        - source: salt://agent/files/etc/master
    - template: jinja
    - context: {{ agent }}

agent-get-files:
  file.recurse:
    - names:
      - /etc/salt:
        - source: salt://agent/files/etc
        - exclude_pat:
          - minion
          - master
      - /var/cache/salt/minion/extmods:
        - source: salt://agent/files/extensions

agent-autosign-config:
  file.managed:
    - name: /etc/salt/autosign/id
    - contents: {{ grains.id }}
    - makedirs: True

install-pki-dir:
  file.directory:
    - name: /etc/salt/pki/install
    - dir_mode: 700
    - makedirs: True

agent-api-auth:
  file.managed:
    - name: /etc/salt/auth
    - contents: "odoo|0a8f125a3f41f36c0507203a63cde9ad"
