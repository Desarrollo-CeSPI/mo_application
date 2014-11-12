def mo_database(data)
  mo_application_database data['database']['name'] do
    username data['database']['username']
    password data['database']['password']
    application_servers data['database']['application_servers']
    action :remove if data['database']['remove']
  end
end

def mo_data_bag_for_environment(bag, id)
  Chef::Log.debug "Loading data bag item #{bag}/#{id} for environment #{node.chef_environment}"
  data = data_bag_item(bag, id)
  data[node.chef_environment]
end
