def mo_data_bag_for_environment(bag, id)
  Chef::Log.info "Loading data bag item [#{bag}/#{id}]"
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


def _mo_application_from_data_bag(cookbook_name, id, ssh_private_key = true)
  # Overwritten data from databag
  data = mo_data_bag_for_environment node[cookbook_name]['databag'], id

  data['ssh_keys'] = Array(data['ssh_keys']) + Array(node['mo_application']['ssh_keys'])
  data['ssh_keys'].uniq!

  yield(data) if block_given? #This allows to validate data bags

  # Deployment ssh_private_key
  if ssh_private_key && !node[cookbook_name]['ssh_private_key']
    data.merge! encrypted_data_bag_item_for_environment(node[cookbook_name]['deployment_databag'],
                                                        node[cookbook_name]['ssh_private_key_databag_item'])
  end
  # Mixin attributes
  Chef::Mixin::DeepMerge.deep_merge!(data, node[cookbook_name].to_hash)
end

def mo_application_from_data_bag(cookbook_name, ssh_private_key = true)
  _mo_application_from_data_bag cookbook_name, node[cookbook_name]['id'], ssh_private_key
end

def mo_multiples_applications_from_data_bag(cookbook_name, ssh_private_key = true, &block)
  mo_data_bag_for_environment(node[cookbook_name]['multiple']['databag'], node[cookbook_name]['multiple']['id']).each do |app|
    data = _mo_application_from_data_bag cookbook_name, app, ssh_private_key do |bag|
      %w(user group path).each do |key|
        raise "Application databag item #{app} does not include #{key} key. Using default in multiple environment is bad" unless bag[key]
      end
    end
    data['id'] = app
    block.call data
  end
end

def mo_application_database_from_data_bag(cookbook_name)
  mo_application_from_data_bag(cookbook_name, false)
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
    values['keys'] = Array(values['keys']) + Array(node['mo_application']['ssh_keys'])
    values['keys'].uniq!
    values['user'] ||= name
    values['group'] ||= name

    yield name, values if block_given?

    setup_dotenv values
    mo_database values

  end
end

def application_url(hash)
  "#{hash['proxy_ssl'] && hash['proxy_ssl']['enabled'] ? 'https':'http'}://#{hash['server_name']}"
end

