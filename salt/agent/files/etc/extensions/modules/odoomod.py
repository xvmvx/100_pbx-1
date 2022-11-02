import logging
import uuid
from salt.utils import json, event

__virtualname__ = 'odoo'

# Import third party libs
try:
    import odoorpc
    HAS_LIBS = True
except ImportError:
    HAS_LIBS = False

log = logging.getLogger(__name__)

TAG='odoo_execute'

def __virtual__():
    '''
    Only load if celery libraries exist.
    '''
    if not HAS_LIBS:
        msg = 'OdooRPC lib not found, odoo module not available.'
        log.warning(msg)
        return False, msg
    # Return virtual module name:
    return 'odoo'


def ping():
    return 'pong'


def execute(model, method, args=[], kwargs={}, timeout=5):
    """
    Execute Odoo method.

    CLI example: odoo.execute res.partner search '[[["name","ilike","admin"]]]'
    """
    reply_tag = uuid.uuid4().hex
    event_bus = event.MinionEvent(__opts__)
    event_bus.fire_event({
        'model': model,
        'method': method,
        'args': args,
        'kwargs': kwargs,
        '_reply_tag': reply_tag}, TAG+'/new')
    try:
        res = event_bus.get_event(
            no_block=False, full=True, wait=timeout,
            tag=TAG+'/ret/'+reply_tag)
    except Exception as e:
        log.error('Odoo RPC %s.%s error: %s', model, method, e)
    if 'data' in res and 'result' in res['data']:
        return res['data']['result']


def notify_user(uid, message, title='Notification',
                warning=False, sticky=False):
    """
    Send notification to Odoo user by his uid.

    CLI examples:
        odoo.notify_user 2 'Hello admin!'
        odoo.notify_user 2 'Error' warning=True sticky=True
    """    
    execute('res.users', 'asterisk_plus_notify', [message, title, uid], {
        'warning': warning,
        'sticky': sticky})
