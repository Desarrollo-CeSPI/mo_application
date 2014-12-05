def mo_application_shared_template(name, &block)
  begin
  shared_dir = ::File.join(new_resource.path,'shared')
  run_context.resource_collection.find("directory[#{shared_dir}]")
  rescue Chef::Exceptions::ResourceNotFound
    # If shared directory is not created, we created for the first call
    directory shared_dir do
      owner new_resource.user
      group new_resource.group
      recursive true
    end
  end

  template(::File.join(shared_dir, name),&block).tap do |t|
    t.source name
    t.owner new_resource.user
    t.group new_resource.group
  end
end

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

def mo_apps_from_databag(bag, id, applications_bag)

  data = data_bag_item(bag, id)

  data['applications'].each do |name|
    values = mo_data_bag_for_environment applications_bag, name
    if values.nil?
      Chef::Log.error "No values found for Applications databag #{applications_bag} item #{name}"
    else
      yield name, values if block_given?
    end
  end

end

def mo_testing_apps_from_databag(bag, id, applications_bag)

  mo_apps_from_databag(bag, id, applications_bag) do |name, values|
    values['keys'] = Array(values['keys']) + Array(node['mo_application']['testing']['ssh_keys'])

    yield name, values if block_given?

    db = values['databases'] && values['databases'].first

    if db
      template "users database conf for #{values['user'] || name}" do
        path lazy { ::File.join(::Dir.home(user),".my.cnf" ) }
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
