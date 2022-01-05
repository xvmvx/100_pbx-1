FROM ubuntu:20.04

RUN apt-update 
RUN apt install -y python3-pip tmux vim iputils-ping
RUN pip3 install /opt/agent

RUN ln -s /opt/agent/salt/ /srv/salt
RUN salt-call -l info state.apply agent

EXPOSE 40000 8000
VOLUME ["/var/spool/asterisk"]

COPY entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
