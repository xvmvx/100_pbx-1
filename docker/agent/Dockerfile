FROM ubuntu:20.04

# Install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install dumb-init ssl-cert tzdata asterisk \
    python3-pip tmux vim iputils-ping sudo \
    && pip3 install salt

# Install Agent
COPY ./ /opt/agent/
RUN mkdir /etc/salt && ln -vs /opt/agent/salt /opt/agent/pillar /srv \
    && salt-call --local state.apply agent

EXPOSE 30000 48008
VOLUME ["/var/spool/asterisk"]

COPY ./docker/agent/entrypoint.sh /
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/entrypoint.sh"]
