{% from "agent/map.jinja" import agent with context %}

generate-minion-id:
  cmd.run:
    - name: python3 -c 'import uuid; open("/etc/salt/minion_id","w").write(str(uuid.uuid4()))'
    - unless: test "`cat /etc/salt/minion_id | wc -c`" = "36"

# Create a local file for local settings.
touch-minion-local-conf:
  file.managed:
    - name: /etc/salt/minion_local.conf
    - contents: ''
    - contents_newline: False
    - unless: test -f /etc/salt/minion_local.conf

# Create a local file for master for possible overrides.
touch-master-local-conf:
  file.managed:
    - name: /etc/salt/master_local.conf
    - contents: ''
    - contents_newline: False
    - unless: test -f /etc/salt/master_local.conf

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
