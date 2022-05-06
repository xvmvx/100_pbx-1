FROM ubuntu:20.04

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
    && salt-call --local state.apply asterisk

VOLUME ["/var/spool/asterisk"]

RUN mv /usr/src/asterisk/configs /usr/local/asterisk-configs \
    && rm -rf /usr/src/asterisk

COPY ./docker/supervisord.conf /etc/supervisor/
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
