agent-run:
{%- if grains.get('init', 'unknown') in ['systemd',] %}
  service.running:
    - name: salt-minion
    - onlyif:
      - runlevel
{%- else %}
  cmd.run:
    - name: salt-minion
    - unless:
        - kill -0 `cat /run/salt-minion.pid`
    - bg: True
{%- endif %}
