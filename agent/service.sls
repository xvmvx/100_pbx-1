agent-service-files:
  file.recurse:
    - name:  /etc/systemd/system/
    - source: salt://agent/systemd/
    - require:
        - agent-pip-reqs

agent-services-enable:
  service.enabled:
    - names:
        - salt-master
        - salt-api
        - salt-minion
    - require:
        - agent-service-files
