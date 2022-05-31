FROM ubuntu:20.04

ENV MINION_AUTOSTART=true ASTERISK_AUTOSTART=true

# Install prerequisites
# jinja==3.0.3 until next release salt-3004.2
RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install \
        supervisor ssl-cert tzdata python3-pip \
        sudo tmux tmate screen vim curl \
        iproute2 iputils-ping telnet net-tools tcpdump sngrep ngrep bind9-dnsutils
    && pip3 install jinja2==3.0.3 \
    && pip3 install salt

# Install Asteirsk and Agent
COPY ./ /opt/agent/
RUN pip3 install /opt/agent/ \
    && odoopbx install agent \
    && odoopbx install asterisk \
    && mv /usr/src/asterisk/configs/samples/ /etc/asterisk/ && rm -rf /usr/src/asterisk

COPY ./docker/pbx/supervisord.conf /etc/supervisor/supervisord.conf
CMD ["/usr/bin/supervisord"]
