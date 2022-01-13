FROM ubuntu:20.04

# Don't re-install Salt & deps everytime a file in agent folder is changed.
RUN apt update && \
  DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y ssl-cert tzdata python3-pip tmux vim iputils-ping dumb-init && \
  pip3 install salt

COPY ./ /opt/agent/
RUN pip3 install /opt/agent && ln -s /opt/agent/salt /srv && ln -s /opt/agent/pillar /srv && \
  salt-call --local state.apply agent

EXPOSE 40000 48008
VOLUME ["/var/spool/asterisk"]

COPY ./docker/agent/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
