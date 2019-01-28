# -*- coding: utf-8 -*-

from dsai import DSAIAuthenticator, DSAISpawner
from jupyter_client.localinterfaces import public_ips


c.JupyterHub.bind_url = 'http://0.0.0.0:8000'

c.JupyterHub.ssl_key = '/etc/jupyterhub/jupyterhub_key.pem'
c.JupyterHub.ssl_cert = '/etc/jupyterhub/jupyterhub_cert.pem'


c.JupyterHub.authenticator_class = DSAIAuthenticator

c.DSAIAuthenticator.group_whitelist = ['COMPANY\\domain^users']

c.JupyterHub.pid_file = '/root/jupyterhub.pid'

c.JupyterHub.cleanup_servers = False

c.JupyterHub.spawner_class = DSAISpawner

c.DSAISpawner.use_internal_ip = True
c.DSAISpawner.remove = True

c.DSAISpawner.spark_driver_port = 30000
c.DSAISpawner.spark_blockmanager_port = 31000
c.DSAISpawner.spark_ui_port = 4500
c.DSAISpawner.spark_max_sessions_per_user = 10


c.DSAISpawner.http_timeout = 60


c.DSAISpawner.user_cgroup_parent = {
    'bank\\user1'    : '/jupyter-cgroup-1', # user 1
    'bank\\user2'    : '/jupyter-cgroup-1', # user 2
    'bank\\user3'    : '/jupyter-cgroup-2', # user 3
}

c.DSAISpawner.cgroup_parent = '/jupyter-cgroup-3'


c.JupyterHub.hub_ip = '0.0.0.0'
c.JupyterHub.hub_connect_ip = public_ips()[0]
