# Returns specified data bag item id for current node's environment
# If Data bag item doesn't exist, it will return an empty Hash
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

# Returns coobbook_name attributes merged with data bag specific attributes
# for node's environment. This will allow to only specify those attributes to
# be overwritten by data bag
def _mo_application_from_data_bag(cookbook_name, id, ssh_private_key = true, data=nil)
  data ||= mo_data_bag_for_environment node[cookbook_name]['databag'], id
  # Add global ssh_keys to speciific keys
  data['ssh_keys'] = Array(data['ssh_keys']) + Array(node['mo_application']['ssh_keys'])
  data['ssh_keys'].uniq!

  # Setup database information that may be encapsulated in a cluster definition
  mo_database_set_all_superuser_info data

  yield(data) if block_given? #This allows to manipulate data from outside

  # Add Deployment ssh_private_key
  if ssh_private_key && !node[cookbook_name]['ssh_private_key']
    data.merge! encrypted_data_bag_item_for_environment(node[cookbook_name]['deployment_databag'],
                                                        node[cookbook_name]['ssh_private_key_databag_item'])
  end
  # Mixin attributes
  Chef::Mixin::DeepMerge.deep_merge!(data, node[cookbook_name].to_hash)
end

# Wrapper for _mo_application_from_data_bag
def mo_application_from_data_bag(cookbook_name, ssh_private_key = true)
  _mo_application_from_data_bag cookbook_name, node[cookbook_name]['id'], ssh_private_key
end

# Wrapper for _mo_application_from_data_bag considering no ssh_private_key
def mo_application_database_from_data_bag(cookbook_name)
  mo_application_from_data_bag(cookbook_name, false)
end

# Will read data bag for the same application multiple times. Used to install the same 
# application multiple times in the same server
def mo_multiples_applications_from_data_bag(cookbook_name, ssh_private_key = true, &block)
  item = data_bag_item(node[cookbook_name]['multiple']['databag'], node[cookbook_name]['multiple']['id'])
  Chef::Log.error("There where no applications found for multiple configuration of #{node[cookbook_name]['multiple']['databag']}/#{node[cookbook_name]['multiple']['id']}") if Array(item['applications']).empty?
  Array(item['applications']).each do |app|
    data = mo_data_bag_for_environment node[cookbook_name]['databag'], app
    #Fail fast if no data bag is defined
    raise "No data bag found for server #{node[cookbook_name]['multiple']['databag']}/#{node[cookbook_name]['multiple']['id']} and application #{node[cookbook_name]['databag']}/#{app}" if data.nil? || data.empty?
    data = _mo_application_from_data_bag(cookbook_name, app, ssh_private_key, data) do |bag|
      %w(user group path).each do |key|
        raise "Application databag item #{app} does not include #{key} key. Using default in multiple environment is bad" unless bag[key]
      end
    end
    data['id'] = app
    block.call data
  end
end

# Read all applications sepcified in data bag item. For each application read, wi will
# try to load other data bag item specified inside applications_bag data bag with each
# item name previously read
def _mo_testing_apps_from_databag(bag, id, applications_bag)
  data_bag_item(bag, id).tap do |data|
    data['applications'].each do |name|
      values = mo_data_bag_for_environment applications_bag, name
      #Fail fast if no data bag is defined
      raise "No data bag found for testing server #{bag}/#{id} and application #{applications_bag}/#{name}" if values.nil? || values.empty?
      yield name, values if block_given?
    end
  end
end


# Wrapper for _mo_testing_apps_from_databag
def mo_testing_apps_from_databag(cookbook_name)
  include_recipe "mo_backup::install"

  bag = node[cookbook_name]['databag']
  id = node.fqdn
  applications_bag = node[cookbook_name]['applications_databag']

  _mo_testing_apps_from_databag(bag, id, applications_bag) do |name, values|
    values['ssh_keys'] = Array(values['ssh_keys']) + Array(node['mo_application']['ssh_keys'])
    values['ssh_keys'].uniq!

    values['user']  ||= name
    values['group']   = name
    values['path']    = ::File.join(node['mo_application']['testing_base_path'],name)
    values['deploy']  = false
    values['id']    ||= name # Needed to name backups
    values['backup'] ||= Hash.new
    values['backup']['archives'] = [ ::File.join(values['path'],'app','shared'), ::File.join(values['path'],'log')]

    yield values if block_given?

    dotconfig values
    mo_database values
    mo_application_backup values
  end
end


