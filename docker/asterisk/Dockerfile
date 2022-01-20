FROM ubuntu:20.04

# Install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install ssl-cert tzdata python3-pip tmux vim iputils-ping \
    && pip3 install salt
 
# Install Agent
COPY ./ /opt/agent
RUN pip3 install salt \
    && ln -s /opt/agent/salt /srv && ln -s /opt/agent/pillar /srv \
    && salt-call --local state.apply asterisk

EXPOSE 8089 5038 65060
VOLUME ["/var/spool/asterisk"]

ENTRYPOINT ["dumb-init"]
CMD /usr/sbin/asterisk -f
