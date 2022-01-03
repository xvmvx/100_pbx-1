{% from "agent/map.jinja" import agent with context %}

agent-generate-minion-id:
  cmd.run:
    - name: python3 -c 'import uuid; open("/etc/salt/minion_id","w").write(str(uuid.uuid4()))'
    - unless: test "`cat /etc/salt/minion_id | wc -c`" = "36"

agent-conf-files:
  file.recurse:
    - names:
      - /etc/salt:
        - source: salt://agent/files/etc
        - template: jinja
        - context: {{ agent }}
      - /var/cache/salt/minion/extmods:
        - source: salt://agent/files/extensions

# Create files for local settings.
agent-conf-files-local:
  file.managed:
    - names:
      - /etc/salt/minion_local.conf
      - /etc/salt/master_local.conf
    - contents: ''
    - contents_newline: False
    - replace: False

agent-autosign-config:
  file.symlink:
    - name: /etc/salt/autosign/id
    - target: /etc/salt/minion_id
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
