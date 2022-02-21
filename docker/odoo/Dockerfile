ARG ODOO_VERSION
ARG ADDONS_SRC

# https://github.com/odoo/docker/blob/master/14.0/Dockerfile
FROM odoo:${ODOO_VERSION}

USER root
COPY odoo/odoo.conf /etc/odoo/odoo.conf
COPY ${ADDONS_SRC} /mnt/addons
RUN ls /mnt/addons \
    && mkdir /mnt/addons_ee /mnt/enterprise \
    && pip3 install -r /mnt/addons/requirements.txt
USER odoo
