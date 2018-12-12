import grp, os, pwd, socket

from dockerspawner import DockerSpawner
from traitlets import Int, Dict, Float
from jupyterhub.auth import PAMAuthenticator


class DSAIAuthenticator(PAMAuthenticator):
    def check_group_whitelist(self, username):
        pw_name = pwd.getpwnam(username).pw_name

        return super().check_group_whitelist(pw_name)


class DSAISpawner(DockerSpawner):
    spark_driver_port = Int(0, min = 0, max = 65535, config = True)
    spark_blockmanager_port = Int(0, min = 0, max = 65535, config = True)
    spark_max_sessions_per_user = Int(0, min = 0, max = 9999, config = True)

    cpu_share = Float(0.0, min = 0.0, config = True)
    group_cpu_share = Dict(config = True)
    user_cpu_share = Dict(config = True)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        volumes = os.getenv('VOLUMES')
        self.volumes = {}
        for volume in volumes.split(' '):
            colon = volume.index(':')

            host_location = volume[2:colon]
            bind_mode = volume[colon + 1:].split(':')

            self.volumes[volume[2:colon]] = {'bind' : bind_mode[0], 'mode' : bind_mode[1]}

    def get_spark_ports(self):
        return (
            self.spark_driver_port + (self.user.id - 1) * self.spark_max_sessions_per_user,
            self.spark_blockmanager_port + (self.user.id - 1) * self.spark_max_sessions_per_user,
            self.spark_max_sessions_per_user
        )

    def get_env(self):
        env = super().get_env()

        user_spark_driver_port, user_spark_blockmanager_port, user_spark_max_retries = self.get_spark_ports()

        env['KRB5CCNAME'] = '/host/tmp/krb5cc_%d' % pwd.getpwnam(self.user.name).pw_uid
        env['HADOOP_CONF_DIR'] = '/etc/dsai/hadoop/'
        env['SPARK_SUBMIT_ARGS'] = (
            "--conf spark.driver.host=%s"
            + " --conf spark.driver.bindAddress=0.0.0.0"
            + " --conf spark.master=yarn"
            + " --conf spark.driver.port=%d"
            + " --conf spark.blockManager.port=%d"
            + " --conf spark.port.maxRetries=%d"
        ) % (os.getenv('HOST_HOSTNAME'), user_spark_driver_port, user_spark_blockmanager_port, user_spark_max_retries)
        env['PYSPARK_SUBMIT_ARGS'] = env['SPARK_SUBMIT_ARGS'] + " pyspark-shell"

        return env

    def set_extra_create_kwargs(self):
        user_spark_driver_port, user_spark_blockmanager_port, user_spark_max_retries = self.get_spark_ports()

        if user_spark_driver_port == 0 or user_spark_blockmanager_port == 0 or user_spark_max_retries == 0:
            return

        ports = {}

        for p in range(user_spark_driver_port, user_spark_driver_port + user_spark_max_retries):
            ports['%d/tcp' % p] = None

        for p in range(user_spark_blockmanager_port, user_spark_blockmanager_port + user_spark_max_retries):
            ports['%d/tcp' % p] = None

        self.extra_create_kwargs = { 'ports' : ports }

    def set_extra_host_config(self):
        extra_host_config = {}

        pw_name = pwd.getpwnam(self.user.name).pw_name

        cpu_share = 0.0
        if self.user.name in self.user_cpu_share:
            cpu_share = self.user_cpu_share[self.user.name]
        else:
            group_found = False
            for g in grp.getgrall():
                if pw_name in g.gr_mem and g.gr_name in self.group_cpu_share:
                    cpu_share = self.group_cpu_share[g.gr_name]

                    group_found = True

                    break

            if not group_found:
                cpu_share = self.cpu_share

        if cpu_share > 0.0:
            extra_host_config['cpu_quota'] = int(100000.0 * cpu_share)
            extra_host_config['cpu_period'] = 100000

        user_spark_driver_port, user_spark_blockmanager_port, user_spark_max_retries = self.get_spark_ports()

        if user_spark_driver_port != 0 and user_spark_blockmanager_port != 0 and user_spark_max_retries != 0:
            port_bindings = {}

            for p in range(user_spark_driver_port, user_spark_driver_port + user_spark_max_retries):
                port_bindings['%d' % p] = ('0.0.0.0', p)

            for p in range(user_spark_blockmanager_port, user_spark_blockmanager_port + user_spark_max_retries):
                port_bindings['%d' % p] = ('0.0.0.0', p)

            extra_host_config['port_bindings'] = port_bindings

        self.extra_host_config = extra_host_config

    def create_object(self):
        current_container = None
        host_name = socket.gethostname()
        for container in self.client.containers():
            if container['Id'][0:12] == host_name:
                current_container = container

                break

        self.image = current_container['Image']

        self.set_extra_create_kwargs()

        return super().create_object()

    def start(self):
        self.set_extra_host_config()

        return super().start()

