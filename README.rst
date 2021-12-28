===============================
The OdooPBX Management Utility
===============================
Features:

* The Agent installation & configuration
* Asterisk installation management
* Odoo installation management

For more details visit the project homepage: https://odoopbx.com

*Latest* Odoo modules require the *latest* odoopbx utility. If you have outdates Odoo modules
see the release history for the corresponding odoopbx version and install it.

For example, to install version 0.80 enter the following command:

.. code::

    pip3 install odoopbx==0.80


ChangeLog
=========
0.105 (2021-)
* ``odoo_events_model`` option added. Defaults to 'asterisk_common.event'.

0.104 (2021-08-31)
##################
* Added jsonrpcserver <= 4.2.0 dependency.

0.103 (2021-07-15)
##################

* Added timeout and as_list parameters to asterisk.manager_action command in order to fix Panoramisk AGI issue.
* Added Odoo re-connect when Agent is started before Odoo and Odoo is not available.

0.102 (2021-07-08)
##################

* Fix Jinja2 version
* Upgrade postgres formula
* switch to state_output mixed

0.101 (2021-07-07)
##################

* Added Odoo executor engine.

0.100 (2021-06-18)
##################

* FastAGI engine is added to ``default.conf`` and is ready to be enabled with just ``fastagi_enabled`` option.

0.99 (2021-06-14)
#################

* Google text-to-speech support added. See https://docs.odoopbx.com/developer_guide/tts.html for details.

0.98 (2021-06-09)
#################

* Isabel support added for the Agent.

0.97 (2021-06-03)
#################

* Agent HTTP Connector bug fix.

0.96 (2021-05-03)
#################

* Salt bug with threded context is solved (https://github.com/saltstack/salt/issues/59962). So we now use Salt >= 3003!

0.95 (2021-04-20)
#################

* Added a new option to the Agent to enable / disable ``!`` command from Asterisk console:
  ``asterisk_shell_enabled`` = False by default. See Agent Options in the docs.

0.94 (2021-04-07)
#################

* Fixed non-critical bug in odoo_connector.py (logger -> log).

0.93 (2021-04-06)
#################

* asterisk_cli_enabled is now False by default. So if you use asterisk_base module you should
  enable the console service with ``odoopbx config set asterisk_cli_enabled true`` and restart the Agent.

0.92 (2021-04-05)
#################

* Fixed a bug with blackist list entry addition.
* Salt 2002.6 is set as dependency as there incompatible change in Salt 3003.
* Fixed a bug when manually added ipset entry to the banned list was not shown in the Odoo banned report.

