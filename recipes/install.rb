include_recipe 'mo_application::ssh_wrapper'
include_recipe 'nginx::default'
include_recipe 'nginx::http_stub_status_module'
include_recipe 'nginx::http_realip_module'
include_recipe 'chef-msttcorefonts::default'
include_recipe 'mo_application::backup'
include_recipe 'mo_monitoring_client'
include_recipe "mo_collectd"
include_recipe 'mo_collectd::plugin_nginx'

mysql_client 'default' do
    action :create
end

node[:mo_application][:packages].each { |p| package  p }

::Chef::Recipe.send(:include, MoApplication::Nginx)

nginx_conf_catch_all_site("default_catch_all_404")
