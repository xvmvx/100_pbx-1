# Docker based deployment
This repository contains OooPBX docker deployment instructions. It's used by the OdooPBX developers.

To switch between versions and database use variables ODOO_DB and ODOO_VERSION. Here is an example to launch Odoo 13.0 with odoopbx_13 database:

```
ODOO_VERSION=13 ODOO_DB=odoopbx_13 docker-compose up -d odoo minion master api
```

See [OdooPBX Installation documentation](https://odoopbx.github.io/docs/administration/installation.html) for more information.

## Local settings
To enable easy updates do not change ``docker-compose.yml``.

Instead add your custom settings to your ``docker-compose.override.yml``.

## Building
To the images use ``docker-compose.dev.yml`` file like the following:
```
docker-compose -f docker-compose.dev.yml build
```
