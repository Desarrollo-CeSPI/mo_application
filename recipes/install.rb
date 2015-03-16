include_recipe 'mo_application::ssh_wrapper'
include_recipe 'nginx::default'
include_recipe 'chef-msttcorefonts::default'
include_recipe 'mysql::client'
include_recipe 'mo_application::backup'

node[:mo_application][:packages].each { |p| package  p }

