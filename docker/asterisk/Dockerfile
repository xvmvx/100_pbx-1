FROM ubuntu:20.04

RUN apt update && \
  DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y ssl-cert tzdata python3-pip tmux vim iputils-ping dumb-init
 
# Don't reinstall Salt on every change in agent's files.
RUN pip3 install salt
COPY ./ /opt/agent
RUN pip3 install /opt/agent && ln -s /opt/agent/salt /srv && ln -s /opt/agent/pillar /srv
RUN salt-call --local state.apply asterisk

EXPOSE 8089 5038 65060
VOLUME ["/var/spool/asterisk"]

ENTRYPOINT ["dumb-init"]
CMD /usr/sbin/asterisk -f
