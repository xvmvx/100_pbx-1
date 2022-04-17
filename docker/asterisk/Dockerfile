FROM ubuntu:20.04

# Install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install dumb-init ssl-cert tzdata \
    python3-pip tmux vim iputils-ping net-tools tcpdump sngrep ngrep screen sudo \
    && pip3 install salt
 
# Install Asterisk
COPY ./ /opt/agent
RUN mkdir /etc/salt && ln -vs /opt/agent/salt /opt/agent/pillar /srv \
    && salt-call --local state.apply asterisk

EXPOSE 8089 5038 65060
VOLUME ["/var/spool/asterisk"]

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/sbin/asterisk", "-f"]
