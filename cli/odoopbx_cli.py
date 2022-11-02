import click
from datetime import datetime, timedelta
import json
import importlib.util
import logging
import os
import requests
import signal
import sys
import shutil
import subprocess
import tempfile
import time
import uuid
import yaml

logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger(__name__)

TYPESCRIPT_PATH = '/var/log/odoopbx-install-'+datetime.now().__format__('%s')+'.log'
CONFIG_PATH = '/etc/salt/odoopbx/minion.conf'


def _config_load(config_path=CONFIG_PATH):
    try:
        config = yaml.load(open(config_path), yaml.SafeLoader)
        if not config:
            config = dict()
    except FileNotFoundError:
        config = dict()
    return config


def _config_save(config, config_path=CONFIG_PATH):
    open(config_path, 'w').write(
        yaml.dump(config, default_flow_style=False, indent=2))


@click.group()
def main():
    # Set the locale.
    if 'utf' not in os.getenv('LANG', '').lower():
        os.environ['LANG'] = os.environ['LC_ALL'] = 'C.UTF-8'

@main.command()
@click.option('--master', type=str, help="Salt master address (optional)")
@click.argument('service')
def install(service, master):
    """
    Install OdooPBX components. 

    Examples:

        \b
        odoopbx install agent
        odoopbx install asterisk
        odoopbx install odoo
        odoopbx install letsencrypt
    """
    options = ''
    if master:
        options += f'--master={master}'
    else:
        file_root = os.path.join(
            os.path.split(os.path.dirname(__file__))[-2], 'salt')
        pillar_root = os.path.join(
            os.path.split(os.path.dirname(__file__))[-2], 'pillar')
        options += '--local --file-root={} --pillar-root={}'.format(
            file_root, pillar_root)
    try:
        subprocess.check_call('script -ec '
            f'"salt-call {options} state.apply {service}" '
            f'{TYPESCRIPT_PATH}',
            shell=True)
    except subprocess.CalledProcessError as e:
        click.secho(f'Error: {e}', err=True, fg='red')
        exit(3)


@main.group(help='Manage salt minion configuration')
def config():
    pass


@config.command(name='get')
@click.argument('option')
@click.option(
    '--local', is_flag=True, help=f'Search the option only in {CONFIG_PATH}')
def config_get(option, local):
    """
    Retreive the value in JSON of a configuration option
    """
    if not local:
        #--local here is about not connecting master
        value = subprocess.check_output(
            f'salt-call --local --out=json config.get {option}', shell=True)
        value = json.loads(value)
        click.echo(json.dumps(value['local']))
    else:
        config = _config_load()
        if option not in config:
            click.secho(
                f'Error: option {option} not found in {CONFIG_PATH}',
                err=True, fg='red')
            exit(4)
        click.echo(json.dumps(config[option]))


@config.command(name='set')
@click.argument('option')
@click.argument('value')
def config_set(option, value):
    """
    Save in minion_local.conf a configuration option passed as JSON.

    Examples:

        odoopbx config set ami_trace_actions true # true and not True
        odoopbx config set ami_trace_events '["Cdr","FullyBooted"]'

    """
    try:
        value = json.loads(value)
    except json.decoder.JSONDecodeError as e:
        # String value
        pass
    config = _config_load()
    if option not in config:
        click.secho('Creating a new local option {}.'.format(option))
    config[option] = value
    _config_save(config)


@config.command(name='del', help=f"Delete a configuration option from {CONFIG_PATH}")
@click.argument('option')
def config_del(option):
    config = _config_load()
    if option not in config:
        click.echo(f'Option {option} not present in {CONFIG_PATH}, nothing to delete.')
        return
    del config[option]
    _config_save(config)


@main.command(help='Start a service.')
@click.option('--after', type=str, help="Only used when run as supervisor eventlistener")
@click.argument('service')
def start(service, after):
    servicectlmap = {'systemd': 'systemctl', 'supervisord': 'supervisorctl'}
    try:
        init = subprocess.check_output('salt-call --local --out=json grains.get init', shell=True)
        init = json.loads(init)['local']
        if after:
            from supervisor.childutils import listener, get_headers
            while True:
                headers, payload = listener.wait()
                #click.secho(f'========== {headers}\n========== {payload}\n', err=True)
                if get_headers(payload)['processname'] == after:
                    click.secho(f'+++++++ starting {service}', err=True)
                    listener.ok()
                    break
                listener.ok()
        res = subprocess.check_output(f'{servicectlmap[init]} start {service}', shell=True)
        click.echo(res)
    except subprocess.CalledProcessError as e:
        click.secho(f'Error: {e}', err=True, fg='red')
    except json.decoder.JSONDecodeError as e:
        click.secho(f'Error: {e}', err=True, fg='red')    

@main.command(help='Stop a service.')
@click.argument('service')
def stop(service):
    servicectlmap = {'systemd': 'systemctl', 'supervisord': 'supervisorctl'}
    try:
        init = subprocess.check_output('salt-call --local --out=json grains.get init', shell=True)
        init = json.loads(init)['local']
        res = subprocess.check_output(f'{servicectlmap[init]} stop {service}', shell=True)
        click.echo(res)
    except subprocess.CalledProcessError as e:
        click.secho(f'Error: {e}', err=True, fg='red')
    except json.decoder.JSONDecodeError as e:
        click.secho(f'Error: {e}', err=True, fg='red')    


@main.group(help='Show information.')
def show():
    pass


@show.command(help='Show system version.', name='version')
def show_version():
    import odoopbx.cli
    click.echo('Odoo CLI version: {}'.format(odoopbx.cli.__version__))


@show.command(help='Show system status.', name='report')
def show_report():
    STARS = '*' * 20
    click.secho('{} SALT VERSIONS {}'.format(STARS, STARS), bold=True)
    os.system('salt-call --local --versions')
    click.secho('{} SALT GRAINS {}'.format(STARS, STARS), bold=True)
    os.system('salt-call --local grains.items')
    click.secho('{} NETWORK PORTS {}'.format(STARS, STARS), bold=True)
    os.system('netstat -atnup | grep LISTEN')
    click.secho('{} PYTHON PROCS {}'.format(STARS, STARS), bold=True)
    os.system('ps auxw | grep python')


if __name__ == '__main__':
    main()
