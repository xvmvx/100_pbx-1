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
    def _initialize(self, url):
        log.info(f'Initialize with {url.geturl()}')
        # Generate new salt api password
        new_password = str(uuid.uuid4())
        request_url = parse.urljoin(url.geturl(), 'asterisk_plus/initialize')
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
        if not 'result' in res:
            log.error('Initialize failed: {}'.format(res))
            return
        elif 'error' in res['result']:
            log.error('Initialize error: {}'.format(res['result']['error']))
            return
        elif 'opts' in res['result']:
            self.user = res['result']['opts']['odoo_user']
            self.password = res['result']['opts']['odoo_password']
            running_config = cli._config_load()
            running_config.update(res['result']['opts'])
            cli._config_save(running_config)
            open('/etc/salt/odoopbx/auth', 'w').write(
                'odoo|'+hashlib.md5(new_password.encode('utf-8')).hexdigest())


    def connect(self, url):
        while self.loop.is_running():
            if not self.user or not self.password:
                self._initialize(url)
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


    async def start(self):
        # Get and parse ODOO_URL
        odoo_url =  os.environ.get('ODOO_URL') or __opts__.get('odoo_url')
        if not odoo_url:
            log.error('ODOO_URL undefined')
            return
        try:
            url = parse.urlparse(odoo_url)
            self.host = url.netloc.split(':')[0]
            self.db = dict(parse.parse_qsl(url.query))['db']
            self.protocol = {
                'https': 'jsonrpc+ssl',
                'http': 'jsonrpc'}[url.scheme]
            self.port = url.port or (80 if url.scheme == 'http' else 443)
        except Exception as e:
            log.error('ODOO_URL %s parse error: %s', odoo_url, e)
            return
        # Set minion's ID & timezone.
        self.minion_id = __opts__.get('id')
        try:
            self.timezone = __salt__['timezone.get_zone']()
        except Exception as e:
            log.error('Timezone get error: %s', e)
            self.timezone = None
        # Get Odoo connection options
        self.user = os.environ.get('ODOO_USER') or __opts__.get('odoo_user')
        self.password = os.environ.get('ODOO_PASSWORD') or __opts__.get('odoo_password')
        # Set trace option
        self.odoo_trace_rpc = __opts__.get('odoo_trace_rpc')
        # Set process name
        salt.utils.process.appendproctitle(self.__class__.__name__)
        self.loop = asyncio.get_event_loop()
        # Create event loop to receive actions as events.
        self.connect(url)
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
        if self.odoo_trace_rpc:
            log.info('Odoo execute: %s', data)
        res = self.odoo.execute_kw(model, method, args, kwargs)
        if self.odoo_trace_rpc:
            log.info('Odoo execute result: %s', res)
        return res


def start():
    log.info('Starting Odoo Executor engine.')
    run(OdooExecutor().start())
