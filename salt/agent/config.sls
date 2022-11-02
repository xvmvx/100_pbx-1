{% from "agent/map.jinja" import agent with context %}

agent-generate-minion-id:
  cmd.run:
    - name: {{ agent.python }} -c 'import uuid; open("/etc/salt/minion_id","w").write(str(uuid.uuid4()))'
    - unless: test "`cat /etc/salt/minion_id | wc -c`" = "36"

agent-etc-files:
  file.recurse:
    - names:
      - /etc/salt:
        - source: salt://agent/files/etc
        - exclude_pat:
          - minion
          - master

agent-conf-files:
  file.managed:
    - names:
      - /etc/salt/minion:
        - source: salt://agent/files/etc/minion
      - /etc/salt/master:
        - source: salt://agent/files/etc/master
    - template: jinja
    - context: {{ agent }}

agent-autosign-config:
  file.symlink:
    - name: /etc/salt/autosign/id
    - target: /etc/salt/minion_id
    - makedirs: True