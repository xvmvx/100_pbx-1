import logging
import salt.utils.event

__virtualname__ = "odoo"

log = logging.getLogger(__name__)


def __virtual__():
    return __virtualname__


def returner(ret):
    event = salt.utils.event.MinionEvent(__opts__)
    # Strip fun_args on return
    ret.pop('fun_args')
    event.fire_event({
        'model': 'asterisk_plus.salt_job',
        'method': 'returner',
        'args': [ret]
    }, 'odoo_execute/new')
    log.debug('Return has been sent to Odoo: %s', ret)
    if __opts__.get('odoo_trace_rpc', False):
        # Suppress file contents logging
        if ret['fun'] in ['asterisk.get_file',
                        'asterisk.get_config',
                        'asterisk.get_all_configs']:
            log.info('{}: {}'.format(ret['jid'], list(ret['return'].keys())))
        else:
            log.info('{}: {}'.format(ret['jid'], ret['return']))
