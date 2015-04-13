template node['mo_application']['ssh_wrapper'] do
    source "ssh_wrapper.erb"
    mode 0775
    variables(key_name: node['mo_application']['deployment_ssh_key_name'])
end
