FROM ubuntu:20.04

ENV API_AUTOSTART=true
ENV MASTER_AUTOSTART=true
ENV MINION_AUTOSTART=true
ENV ASTERISK_AUTOSTART=true

COPY ./ /opt/agent/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install \
        supervisor ssl-cert tzdata python3-pip \
        sudo tmux tmate screen vim curl \
        iproute2 iputils-ping telnet net-tools tcpdump sngrep ngrep bind9-dnsutils \
    # the same as `pip3 install odoopbx`
    && pip3 install /opt/agent/ \
    # print-out versions for debugging purposes
    && odoopbx show report \
    # install salt-master salt-api salt-minion
    && odoopbx install agent \
    # install asterisk
    && odoopbx install asterisk \
    # save config samples into /etc/asterisk/samples
    && mv /usr/src/asterisk/configs/samples/ /etc/asterisk/ \
    # remove asterisk sources to reduce the size of the image 
    && rm -rf /usr/src/asterisk \
    # put supervisor configs in place
    && cp -av ./docker/supervisord.conf ./docker/supervisord.d/ /etc/

CMD ["/usr/bin/supervisord"]
