# Docker based deployment
This repository contains OooPBX docker deployment instructions. It's used by the OdooPBX developers.

By default Odoo version 15.0 and database name odoopbx_15 are used.

To switch between versions and database use variables ODOO_DB and ODOO_VERSION.
Here is an example to launch Odoo 14.0 with odoopbx_14 database:

```
ODOO_VERSION=14.0 ODOO_DB=odoopbx_14 docker-compose up demo
```

See [OdooPBX Installation documentation](https://odoopbx.github.io/docs/administration/installation.html) for more information.

## Local settings
To enable easy updates do not change ``docker-compose.yml``.

Instead add your custom settings to your ``docker-compose.override.yml``.
See ``docker-compose.override.yml.example`` for an example.

## Building
To build the images locally use ``docker-compose.dev.yml`` file like the following:
```
ODOO_VERSION=14.0 ODOO_DB=odoopbx_14 docker-compose -f docker-compose.dev.yml build
```
