ARG ODOO_VERSION
FROM odoo:${ODOO_VERSION}
# Note! Odoo images set own ODOO_VERSION value. So if set ODOO_VERSION=14 as build ARG it is 14.0 after FROM instruction.
USER root
COPY odoo/odoo.conf /etc/odoo/odoo.conf
RUN apt-get update && apt-get install -y unzip \
    && mkdir /mnt/addons /mnt/addons_ee /mnt/enterprise \
    && cd /mnt/addons \
    && curl -L https://github.com/odoopbx/addons/archive/refs/heads/${ODOO_VERSION}.zip -o addons.zip \
    && unzip addons.zip \
    && pip3 install -r addons-${ODOO_VERSION}/requirements.txt \
    && mv addons-${ODOO_VERSION}/* . \
    && rm -rf addons-${ODOO_VERSION} addons.zip
USER odoo
