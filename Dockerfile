FROM alpine:3

ENV MUSL_LOCPATH=/usr/local/share/i18n/locales/musl LANG=C.UTF-8
RUN apk add --update py3-pip python3-dev build-base linux-headers zeromq-dev tini asterisk \
    util-linux git swig cmake make musl-dev openssl-dev gcc gettext-dev libintl && cd /tmp && \
    git clone https://github.com/rilian-la-te/musl-locales.git && \
    cd /tmp/musl-locales && cmake . && make && make install && \
    addgroup ssl-cert

# Wheel is required.
RUN pip3 install wheel
# Why this is not run from install.sls?
RUN pip3 install M2Crypto

COPY ./ /srv/agent/
RUN pip3 install /srv/agent
RUN mkdir /etc/salt && echo -e 'state_output: mixed\nfile_roots:\n  base:\n    - /srv/agent/salt' > /etc/salt/minion && cat /etc/salt/minion && salt-call -l info --local state.apply odoopbx
RUN rm -rf /srv/agent

EXPOSE 40000
VOLUME ["/var/lib/asterisk", "/var/spool/asterisk", "/var/log/asterisk", "/etc/asterisk", "/var/run/asterisk", "/srv/odoopbx"]

COPY entrypoint.sh /entrypoint.sh
RUN apk add tmux
CMD /entrypoint.sh
