{%- if grains.get('init') in ['systemd',] %}
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

agent-services-run:
  service.running:
    - names:
        - salt-master
        - salt-api
    - require:
        - agent-service-files

{%- else %}
agent-launch-in-background:
  cmd.run:
    - names:
        - salt-master -l error:
            - unless:
                - kill -0 `cat /run/salt-master.pid`
        - salt-api -l error:
            - unless:
                - kill -0 `cat /run/salt-api.pid`
    - bg: True
    - hide_output: True
{%- endif %}
