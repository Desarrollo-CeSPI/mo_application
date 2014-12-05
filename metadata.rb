name             'mo_application'
maintainer       'Christian A. Rodriguez & Leandro Di Tommaso'
maintainer_email 'chrodriguez@gmail.com leandro.ditommaso@mikroways.net'
license          'MIT'
description      'Provides resources for almost any application'
long_description 'Installs/Configures mo_application'
version          '0.1.27'

depends         'mysql',      '~> 5.6.0'
depends         'database',   '~> 2.3.0'
depends         'user',       '~> 0.3.1'
depends         'nscd',       '~> 0.12.0'
depends         'logrotate',  '~> 1.7.0'
depends         'hostsfile',  '~> 2.4.5'
depends         'nginx',      "~> 2.7.4"
depends         'nginx_conf', "~> 0.2.4"
depends         'chef-sugar', "~> 2.4.1"
depends         'chef-msttcorefonts', "~> 0.9.0"
