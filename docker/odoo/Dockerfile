ARG ODOO_VERSION
FROM odoo:${ODOO_VERSION:-14}
USER root
RUN mkdir /mnt/addons /mnt/addons_ee /mnt/enterprise && \
    pip3 install humanize salt-pepper lameenc SpeechRecognition
USER odoo
