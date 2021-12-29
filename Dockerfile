FROM alpine:3

RUN apk add py3-pip python3-dev build-base linux-headers zeromq-dev tini asterisk util-linux
RUN pip3 install wheel
ENV MUSL_LOCPATH=/usr/local/share/i18n/locales/musl
RUN apk add --update git cmake make musl-dev gcc gettext-dev libintl
RUN cd /tmp && git clone https://github.com/rilian-la-te/musl-locales.git
RUN cd /tmp/musl-locales && cmake . && make && make install
RUN addgroup ssl-cert

ENV LANG=C.UTF-8

RUN pip3 install jinja2==2.11.3
RUN pip3 install salt 
RUN pip3 install click 
RUN pip3 install google-cloud-texttospeech

 RUN pip3 install aiorun ipsetpy OdooRPC setproctitle terminado tornado-httpclient-session cherrypy

COPY ./ /srv/odoopbx/
RUN pip3 install /srv/odoopbx
COPY ./salt/agent/files/extensions/ /var/cache/salt/minion/extmods/
COPY ./salt/agent/files/etc/ /etc/salt/
RUN rm -rf /srv/odoopbx

RUN odoopbx init --auth NubdupodLu


EXPOSE 40000 4574
VOLUME ["/var/lib/asterisk", "/var/spool/asterisk", "/var/log/asterisk", "/etc/asterisk", "/var/run/asterisk", "/srv/odoopbx", "/etc/odoopbx"]


CMD tini -- /usr/bin/env salt-minion -l info

