'''
This is Asterisk PBX Salt module
'''
from __future__ import absolute_import, print_function, unicode_literals
import asyncio
from aiorun import run
import concurrent.futures
import logging
import os
import time
import salt.utils.event
import salt.utils.process
import requests
import uuid
import hashlib
import copy
from salt.utils import json
from urllib import parse
from odoopbx import cli

# Import third party libs
try:
    import odoorpc
    HAS_LIBS = True
except ImportError:
    HAS_LIBS = False


log = logging.getLogger(__name__)


def __virtual__():
    if not HAS_LIBS:
        msg = 'OdooRPC lib not found, Odoo Executor module not available.'
        log.warning(msg)
        return False, msg
    return True


class OdooExecutor:
    def _initialize(self):
        request_url = parse.urljoin(self.url, 'asterisk_plus/initialize')
        log.info(f'Initialize with {request_url}')
        # Get minion's ID
        self.minion_id = __opts__.get('id')
        # Try to get timezone only once
        if self.timezone == None:
            try:
                self.timezone = __salt__['timezone.get_zone']()
            except Exception as e:
                log.error('Timezone get error: %s', e)
                self.timezone = False
        # Generate new salt api password
        new_password = str(uuid.uuid4())
        request_data = {
            'db': self.db,
            'id': self.minion_id,
            'saltapi_passwd': new_password,
            'tz': self.timezone}
        try:
            res = requests.post(request_url, json=request_data).json()
        except Exception as e:
            log.error('Initialize exception: {}'.format(e))
            return
        if 'error' in res:
            if 'message' in res['error']:
                log.error('Initialize error1: {}'.format(res['error']['message']))
            else:
                log.error('Initialize error2: {}'.format(res['error']))
            return
        elif not 'result' in res:
            log.error('Initialize no result: {}'.format(res))
            return
        elif 'error' in res['result']:
            log.error('Initialize error3: {}'.format(res['result']['error']))
            return
        elif 'opts' in res['result']:
            self.user = res['result']['opts']['odoo_user']
            self.password = res['result']['opts']['odoo_password']
            running_config = cli._config_load()
            running_config.update(res['result']['opts'])
            cli._config_save(running_config)
            open('/etc/salt/odoopbx/auth', 'w').write(
                'odoo|'+hashlib.md5(new_password.encode('utf-8')).hexdigest())
            log.info('Initialize Success')


    def connect(self):
        while self.loop.is_running():
            if not self.user or not self.password:
                log.info('Odoo user and/or password not specified')
                if self.url:
                    self._initialize()
                else:
                    log.error('Cannot initialize without odoo_url')
                    break
            if not self.user or not self.password:
                time.sleep(10)
                continue
            try:
                log.info(
                    'Connecting to Odoo %s://%s@%s:%s/%s...',
                    self.protocol, self.user, self.host, self.port, self.db)
                self.odoo = odoorpc.ODOO(
                    self.host, port=self.port, protocol=self.protocol)
                self.odoo.login(self.db, self.user, self.password)
                log.info('Logged into Odoo.')
                break
            except Exception as e:
                log.error('Cannot connect to Odoo: %s', e)
                time.sleep(1)
                if 'Access Denied' in str(e):
                    time.sleep(30)
                    self._initialize()


    async def start(self):
        # Get db name from environment or config
        self.db = os.environ.get('ODOO_DB') or __opts__.get('odoo_db')
        # Get  ODOO_URL. Example: http://127.0.0.1:8069/?db=dbname
        self.url =  os.environ.get('ODOO_URL') or __opts__.get('odoo_url')
        # TimeZone not defined by default
        self.timezone = None
        # Get connection parameters
        if self.url:
            try:
                url = parse.urlparse(self.url)
                self.host = url.netloc.split(':')[0]
                self.protocol = {
                    'https': 'jsonrpc+ssl',
                    'http': 'jsonrpc'}[url.scheme]
                self.port = url.port or (80 if url.scheme == 'http' else 443)
                if not self.db:
                    self.db = dict(parse.parse_qsl(url.query))['db']
            except Exception as e:
                log.error('ODOO_URL %s parse error: %s', self.url, e)
                return
        else:
            self.host = __opts__.get('odoo_host', '127.0.0.1')
            self.port = __opts__.get('odoo_port', '8069')
            self.protocol = {
                True: 'jsonrpc+ssl',
                False: 'jsonrpc'}[__opts__.get('odoo_use_ssl', False)]
        # Get Odoo connection options
        self.user = os.environ.get('ODOO_USER') or __opts__.get('odoo_user')
        self.password = os.environ.get('ODOO_PASSWORD') or __opts__.get('odoo_password')
        # Set trace option
        self.odoo_trace_rpc = __opts__.get('odoo_trace_rpc')
        # Set process name
        salt.utils.process.appendproctitle(self.__class__.__name__)
        self.loop = asyncio.get_event_loop()
        # Create event loop to receive actions as events.
        self.connect()
        await self.execute_event_loop()

    async def execute_event_loop(self):
        log.debug('Odoo Execute event loop started.')
        event = salt.utils.event.MinionEvent(__opts__)
        while True:
            evdata = event.get_event(tag='odoo_execute/new',
                                     no_block=True)
            # TODO: Connect to Salt's tornado eventloop.
            try:
                await asyncio.sleep(0.01)
            except concurrent.futures._base.CancelledError:
                return
            if evdata:
                _stamp = evdata.pop('_stamp', False) # Remove this.
                reply_tag = evdata.pop('_reply_tag', False)
                try:
                    res = await self.execute(evdata)
                    if reply_tag:
                        # Send back the result over salt event bus
                        event.fire_event_async({"result": res}, 'odoo_execute/ret/'+reply_tag)
                except Exception as e:
                    log.error('Execute %s error: %s', evdata, e)

    async def execute(self, data):
        model = data.get('model')
        method = data.get('method')
        args = data.get('args', [])
        kwargs = data.get('kwargs', {})
        # Print request if enabled. Returner has it's own log message
        if self.odoo_trace_rpc and method != 'returner':
            # Suppress file_data contents in logger
            cut_args = copy.deepcopy(args)
            try:
                if 'file_data' in args[0]['return']:
                    cut_args[0]['return']['file_data'] = '***'
            except:
                pass
            finally:
                log.info('%s.%s %s %s', model, method, cut_args, kwargs)
        # Execute Odoo method
        res = self.odoo.execute_kw(model, method, args, kwargs)
        # Print result if enabled
        if self.odoo_trace_rpc:
            log.info('Result: %s', res)
        return res


def start():
    log.info('Starting Odoo Executor engine.')
    run(OdooExecutor().start())
