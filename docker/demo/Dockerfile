FROM ubuntu:20.04
ARG ODOO_VERSION=15.0
ARG ODOO_DB=odoopbx_15
ENV ODOO_VERSION=$ODOO_VERSION ODOO_DB=$ODOO_DB
ENV POSTGRES_AUTOSTART=true ODOO_AUTOSTART=true ASTERISK_AUTOSTART=true SALT_AUTOSTART=true

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
    && salt-call --local state.apply odoopbx pillar="{'odoo': {'version': \"$ODOO_VERSION\"},}" \
    && mv /usr/src/asterisk/configs/samples/ /etc/asterisk/ && rm -rf /usr/src/asterisk

COPY ./docker/demo/supervisord.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord"]
