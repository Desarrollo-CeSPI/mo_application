def mo_database(data)
  mo_application_database data['database']['name'] do
    username data['database']['username']
    password data['database']['password']
    application_servers data['database']['application_servers']
    action :remove if data['database']['remove']
  end
end

def mo_data_bag_for_environment(bag, id)
  Chef::Log.debug "Loading data bag item #{bag}/#{id}"
  data = data_bag_item(bag, id)
  if data[node.chef_environment]
    Chef::Log.debug "Using #{node.chef_environment} as the key"
    data[node.chef_environment]
  else
    Chef::Log.debug "#{node.chef_environment} key does not exist, using `default`"
    data['default']
  end
end
