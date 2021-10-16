agent-run:
{%- if grains.get('init', 'unknown') in ['systemd',] %}
  service.running:
    - names:
      - salt-master
      - salt-api
      - salt-minion
    - onlyif:
      - runlevel
{%- else %}
  cmd.run:
    - names:
      - salt-master:
        - unless:
          - kill -0 `cat /run/salt-master.pid`
      - salt-api:
        - unless:
          - kill -0 `cat /run/salt-api.pid`
      - salt-minion:
        - unless:
          - kill -0 `cat /run/salt-minion.pid`
    - bg: True
{%- endif %}
