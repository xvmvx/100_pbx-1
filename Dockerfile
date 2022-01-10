FROM ubuntu:20.04

RUN apt update && \
  DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y ssl-cert tzdata python3-pip tmux vim iputils-ping dumb-init

# Don't re-install Salt & deps everytime a file in agent folder is changed.
RUN pip3 install salt
COPY ./ /opt/agent/
RUN pip3 install /opt/agent && ln -s /opt/agent/salt /srv
RUN salt-call --local state.apply agent

EXPOSE 40000 8000
VOLUME ["/var/spool/asterisk"]

ENTRYPOINT ["dumb-init"]
CMD echo "Specify Salt process to run!"
