default['mo_application']['packages']=[]
default['mo_application']['server_names']=[]
default['mo_application']['ssh_wrapper'] = '/usr/bin/ssh_wrapper'
default['mo_application']['testing']['ssh_keys'] = []
default['nscd']['server_user']= 'nobody'
default['nginx']['default_site_enabled'] = false
default['nginx']['server_names_hash_bucket_size'] = 128
default['nginx']['server_tokens'] = 'off'
default['nginx']['client_max_body_size'] = '20m'
default['nginx']['client_body_buffer_size'] = '128k'


default['mo_application']['mo_backup']['user'] = 'root'
default['mo_application']['mo_backup']['database']['mysql']['username'] = 'backup'
default['mo_application']['mo_backup']['database']['mysql']['password'] = 'backup_pass'
default['mo_application']['mo_backup']['archive']['use_sudo'] = false
default['mo_application']['mo_backup']['compress'] = true

# Not used
#default['mo_application']['mo_backup']['encryptor'] = "encryptor_databag_item"

default['mo_application']['mo_backup']['storages'] = []
# Sample storage data:
# default['mo_application']['mo_backup']['storages'] = [ { "id": "sftp1" } ]

default['mo_application']['mo_backup']['mail'] = {}
# Sample mail data:
# default['mo_application']['mo_backup']['mail'] =  {
#   "mail_id": "mail_databag_item",
#   "on_success": "false",
#   "from": "user@domain.tld"
# }
