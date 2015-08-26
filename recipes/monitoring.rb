include_recipe 'mo_monitoring_client'

check_name = mo_application_custom_monitoring_check_script

file check_name do
  content <<-SCRIPT
#!/bin/bash -l
cd ~/application/current
$@
  SCRIPT
  mode "755"
end

sudo "nrpe_custom_mo_application" do
  user      node['nrpe']['user']
  runas     'ALL,!root'
  commands  ["#{check_name} ?*"]
  nopasswd  true
  defaults ["!env_reset"]
  action :install
end
