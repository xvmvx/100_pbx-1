FROM ubuntu:20.04
ENV ODOO_VERSION 15.0
ENV ODOO_DB odoopbx_15

# Install prerequisites
# jinja==3.0.3 until next release salt-3004.2
RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install \
        supervisor ssl-cert tzdata python3-pip \
        tmux tmate screen vim iproute2 iputils-ping telnet net-tools tcpdump sngrep ngrep sudo \
    && pip3 install jinja2==3.0.3 \
    && pip3 install salt

# Install Asteirsk and Agent
COPY ./ /opt/agent/
RUN mkdir /etc/salt && ln -vs /opt/agent/salt /opt/agent/pillar /srv \
    && salt-call --local state.apply agent \
    && salt-call --local state.apply asterisk \
    && mv /usr/src/asterisk/configs/samples/ /etc/asterisk/ && rm -rf /usr/src/asterisk

COPY ./docker/pbx/supervisor.conf /etc/supervisor/
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
