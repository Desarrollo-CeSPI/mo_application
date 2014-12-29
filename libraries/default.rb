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
    t.source "#{name}.erb"
    t.owner new_resource.user
    t.group new_resource.group
  end
end

def mo_database(data)
  run_context.include_recipe "database::mysql"
  data['databases'].each do | database |
    mo_application_database database['name'] do
      username database['username']
      password database['password']
      application_servers data['application_servers']
      action :remove if database['remove']
    end
  end
end

def mo_data_bag_for_environment(bag, id)
  Chef::Log.info "Loading data bag item #{bag}/#{id}"
  data = data_bag_item(bag, id) rescue Hash.new
  if data[node.chef_environment]
    Chef::Log.info "Using #{node.chef_environment} as the key"
    data[node.chef_environment]
  elsif data['default']
    Chef::Log.error "#{node.chef_environment} key does not exist, using `default`"
    data['default'] 
  else
    Chef::Log.error "Data bag #{bag}/#{id} does not exists. Returning empty Hash!"
    Hash.new
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

def setup_dotenv(data)
  if data['user'] && data['databases']
    db = data['databases'] && data['databases'].first
    if db
      template "users database conf for #{data['user']}" do
        path lazy { ::File.join(::Dir.home(data['user']),".my.cnf" ) }
        owner data['user']
        source 'my.cnf.erb'
        cookbook 'mo_application'
        variables(username: db['username'],
                  password: db['password'],
                  host: db['host'])
      end
    end
  end
end

def mo_testing_apps_from_databag(bag, id, applications_bag)

  mo_apps_from_databag(bag, id, applications_bag) do |name, values|
    values['keys'] = Array(values['keys']) + Array(node['mo_application']['testing']['ssh_keys'])
    values['user'] ||= name
    values['group'] ||= name

    yield name, values if block_given?

    setup_dotenv values
    mo_database values

  end
end

def mo_application_from_data_bag(cookbook_name, ssh_private_key = true)
  # Overwritten data from databag
  data = mo_data_bag_for_environment node[cookbook_name]['databag'], node[cookbook_name]['id']

  # Deployment ssh_private_key
  if ssh_private_key && !node[cookbook_name]['ssh_private_key']
    data.merge! encrypted_data_bag_item_for_environment(node[cookbook_name]['deployment_databag'],
                                                        node[cookbook_name]['ssh_private_key_databag_item'])
  end
  # Mixin attributes
  Chef::Mixin::DeepMerge.deep_merge!(data, node[cookbook_name].to_hash)
end

def mo_application_database_from_data_bag(cookbook_name)
  mo_application_from_data_bag(cookbook_name, false)
end
