{% from "agent/map.jinja" import agent with context %}

{% if grains.osfinger.startswith('CentOS') %}
agent-pkg-reqs-CentOS:
  pkg.installed:
    - names:
      - epel-release
{% endif %}

agent-pkg-reqs:
{% if grains.osfinger.startswith('Issabel') %}
  cmd.run:
    - name: yum -y install {{ agent.pkgs|join(' ') }}
{% else %}
  pkg.installed:
    - pkgs: {{ agent.pkgs }}
    - refresh: true
{% endif %}

{% if grains.osfinger in ['Sangoma Linux-7',] %}
agent-pip-upgrade:
  pip.installed:
    - name: pip
    - upgrade: True
    - reload_modules: True
{% endif %}

agent-pip-reqs:
  pip.installed:
    - pkgs:
      - aiorun
      - ipsetpy
      - setproctitle
      - terminado
      - tornado-httpclient-session
      - cherrypy
      - 'panoramisk @ https://github.com/litnimax/panoramisk/archive/master.zip'
      - odoorpc
      {%- for item in agent.pypi_pkgs %}
      - {{ item }}
      {%- endfor %}
    - require:
      - agent-pkg-reqs
    - reload_modules: True

agent-locale:
  locale.present:
    - name: {{ agent.get('locale', 'C.UTF-8') }}

agent-grains-update:
  grains.present:
    - name: letsencrypt:domainsets:fqdn
    - value:
        - '{{ salt['config.get']('fqdn') }}'
    - force: True
