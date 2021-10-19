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

agent-pip-panoramisk:
  pip.installed:
    - pkgs:
      - https://github.com/litnimax/panoramisk/archive/master.zip
    - unless:
      - pip3 show panoramisk

agent-pip-reqs:
  pip.installed:
    - pkgs:
      - aiorun
      - ipsetpy
      - OdooRPC
      - pastebin
      - setproctitle
      - terminado
      - tornado-httpclient-session
      - cherrypy
        # wait for https://github.com/saltstack/salt/issues/60188 resolved
      - 'jinja2==2.11.3'
      {%- if agent.pypi_pkgs | d(False) %}
      {%- for item in agent.pypi_pkgs %}
      - {{ item }}
      {%- endfor %}
      {%- endif %}
    - require:
      - agent-pkg-reqs
    - retry: True
    - reload_modules: True

agent-pip-upgrade:
  cmd.run:
    - name: pip3 install --upgrade pip
    - reload_modules: true
    - onfail:
      - agent-pip-reqs

agent-locale:
  locale.present:
    - name: {{ agent.get('locale', 'C.UTF-8') }}

agent-grains-update:
  grains.present:
    - name: letsencrypt:domainsets:fqdn
    - value:
        - '{{ salt['config.get']('fqdn') }}'
    - force: True
