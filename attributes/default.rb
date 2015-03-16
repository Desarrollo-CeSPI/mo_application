default['mo_application']['packages']=[]
default['mo_application']['server_names']=[]
default['mo_application']['ssh_wrapper'] = '/usr/bin/ssh_wrapper'
default['mo_application']['ssh_keys'] = []
default['nscd']['server_user']= 'nobody'
default['nginx']['default_site_enabled'] = false
default['nginx']['server_names_hash_bucket_size'] = 128
default['nginx']['server_tokens'] = 'off'
default['nginx']['client_max_body_size'] = '20m'
default['nginx']['client_body_buffer_size'] = '128k'


default['mo_application']['backup']['database']['mysql']['username'] = 'backup'
default['mo_application']['backup']['database']['mysql']['password'] = 'backup_pass'
default['mo_application']['backup']['database']['mysql']['additional_options'] = ["--single-transaction", "--flush-logs", "--master-data=2", "--quick"]

default['mo_application']['backup']['user'] = "root"
default['mo_application']['backup']['group'] = "root"

default['mo_application']['backup']['ssh_key']['databag'] = "backup_keys"
default['mo_application']['backup']['ssh_key']['id'] = "backup_user"


# Data bags used for backups. They must be encrypted
default['mo_application']['backup']['storages_databag'] = "backup_storages"
default['mo_application']['backup']['syncers_databag'] = "backup_syncers"
default['mo_application']['backup']['notifiers_databag'] = "backup_notifiers"

# Array of backup storages databag items within node[mo_application][backup][storages_databag] databaga
default['mo_application']['backup']['storages'] = []
# Array of backup syncers databag items within node[mo_application][backup][syncers_databag] databaga
default['mo_application']['backup']['syncers'] = []
# Array of backup notifiers databag items within node[mo_application][backup][notifiers_databag] databaga
default['mo_application']['backup']['notifiers'] = []
