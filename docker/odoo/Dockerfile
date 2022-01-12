ARG ODOO_VERSION
FROM odoo:${ODOO_VERSION}
# Note! Odoo images set own ODOO_VERSION value. So if set ODOO_VERSION=14 as build ARG it is 14.0 after FROM instruction.
USER root
RUN apt update && apt install -y unzip
RUN mkdir /mnt/addons /mnt/addons_ee /mnt/enterprise && \
    pip3 install humanize salt-pepper lameenc SpeechRecognition
# Download the addons.
RUN    curl -L https://github.com/odoopbx/addons/archive/refs/heads/${ODOO_VERSION}.zip -o /mnt/addons/${ODOO_VERSION}.zip && \
    cd /mnt/addons/ && unzip ${ODOO_VERSION}.zip && \
    mv addons-${ODOO_VERSION}/* . && rm -rf addons-${ODOO_VERSION} ${ODOO_VERSION}.zip
USER odoo