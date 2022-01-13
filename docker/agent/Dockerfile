FROM ubuntu:20.04

# Don't re-install Salt & deps everytime a file in agent folder is changed.
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install ssl-cert tzdata \
  && apt-get -y install python3-pip tmux vim iputils-ping \
  && pip3 install salt

COPY ./ /opt/agent/
RUN mkdir /etc/salt && ln -s /opt/agent/salt /srv && ln -s /opt/agent/pillar /srv \
  && salt-call --local state.apply agent

EXPOSE 30000 48008
VOLUME ["/var/spool/asterisk"]

COPY ./docker/agent/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
