import logging
import salt.utils.event

__virtualname__ = "odoo"

log = logging.getLogger(__name__)


def __virtual__():
    return __virtualname__


def returner(ret):
    event = salt.utils.event.MinionEvent(__opts__)
    # Suppress put_config file contents on returner
    if ret['fun'] == 'asterisk.put_config':
        ret['fun_args'][1] = '****'
    event.fire_event({
        'model': 'asterisk_plus.salt_job',
        'method': 'returner',
        'args': [ret]
    }, 'odoo_execute/new')
    log.debug('Return has been sent to Odoo: %s', ret)
    if __opts__.get('odoo_trace_rpc', False):
        if ret['fun'] in ['asterisk.get_config', 'asterisk.get_file']:
            log.info('{jid} {fun} {fun_args}: ***'.format_map(ret))
        else:
            log.info('{jid} {fun} {fun_args}: {return}'.format_map(ret))
