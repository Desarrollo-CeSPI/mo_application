name             'mo_application'
maintainer       'Christian A. Rodriguez & Leandro Di Tommaso'
maintainer_email 'chrodriguez@gmail.com leandro.ditommaso@mikroways.net'
license          'MIT'
description      'Provides resources for almost any application'
long_description 'Installs/Configures mo_application'
version          '1.2.0'

depends         'database',             '~> 4.0.3'
depends         'user',                 '~> 0.4.0'
depends         'nscd',                 '~> 0.12.0'
depends         'logrotate',            '~> 1.7.0'
depends         'nginx',                '~> 2.7.4'
depends         'nginx_conf',           '~> 1.0.0'
depends         'chef-sugar',           '~> 2.5.0'
depends         'chef-msttcorefonts',   '~> 0.9.0'
depends         'mo_backup',            '~> 0.1.40'
depends         'mo_mysql',             '~> 1.1.0'
depends         'mysql2_chef_gem',      '~> 1.0.1'
depends         'mo_monitoring_client', '~> 1.0.0'
depends         'mo_collectd',          '~> 1.0.4'
