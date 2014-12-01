def mo_database(data)
  mo_application_database data['database']['name'] do
    username data['database']['username']
    password data['database']['password']
    application_servers data['application_servers']
    action :remove if data['database']['remove']
  end
end

def mo_data_bag_for_environment(bag, id)
  Chef::Log.info "Loading data bag item #{bag}/#{id}"
  data = data_bag_item(bag, id)
  if data[node.chef_environment]
    Chef::Log.info "Using #{node.chef_environment} as the key"
    data[node.chef_environment]
  else
    Chef::Log.error "#{node.chef_environment} key does not exist, using `default`"
    data['default']
  end
end

def mo_testing_apps_from_databag(bag, id)

  data = data_bag_item(bag, id)

  data['applications'].each do |name, values|

    values['keys'] = Array(values['keys']) + Array(node['mo_application']['testing']['ssh_keys'])

    yield name, values if block_given?

    db = values['databases'] && values['databases'].first

    if db
      template "/home/#{values['user'] || name}/.my.cnf" do
        owner values['user'] || name
        source 'my.cnf.erb'
        variables(username: db['username'] || db['name'],
                  password: db['password'],
                  host: db['host'])
        not_if { values['remove'] }
      end

      values['databases'].each do | database |
        mo_database 'database' => database.merge('remove' => values['remove']), 
                    'application_servers' => values['application_servers']
      end
    end

  end

end
