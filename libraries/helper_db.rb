def load_mysql_gem
  run_context.resource_collection.find("mysql2_chef_gem[default]")
  rescue Chef::Exceptions::ResourceNotFound
    # resource_collection#find raises an exception. In that case we define this resource for the first time
    mysql2_chef_gem 'default' do
        action :install
    end
end

def mo_database_set_superuser_info(database_data)
  if database_data['cluster']
    database_data.merge! mo_mysql_data_for_cluster(database_data['cluster'])
    master = search('node',"chef_environment:#{node.chef_environment} AND tags:mysql_master AND cluster_name:#{database_data['cluster']}")
    host = master.first
    fail "Did not find a MySQL cluster named #{database_data['cluster']} tagged as mysql_master for environment #{node.chef_environment}"  if host.nil?
    database_data['host'] ||= host.fqdn
  end
  database_data['application_servers'] = (Array(database_data['application_servers']) << node.ipaddress << "127.0.0.1").uniq
end

def mo_database(data)
  load_mysql_gem
  (data['databases'] || Hash.new).each do | name, database |
    mo_database_set_superuser_info(database.merge!('application_servers' => data['application_servers']))
    mo_application_database database['name'] do
      username database['username']
      password database['password']
      superuser_host database['host']
      superuser_password database['superuser_password']
      superuser database['superuser']
      application_servers database['application_servers']
      action :remove if database['remove']
    end
  end
end
