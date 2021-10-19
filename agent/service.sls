{% from "agent/map.jinja" import agent with context %}

agent-service-files:
  file.recurse:
    - name:  /etc/systemd/system/
    - source: salt://agent/systemd/
    - template: jinja
    - context: {{ agent }}
    - require:
        - agent-pip-reqs

agent-services-enable:
  service.running:
    - names:
        - salt-master
        - salt-api
        - salt-minion
    - enable: True
    - require:
        - agent-service-files
