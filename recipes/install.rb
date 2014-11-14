include_recipe 'mo_application::_ssh_wrapper'
include_recipe 'nginx::default'

node[:mo_application][:packages].each { |p| package }
