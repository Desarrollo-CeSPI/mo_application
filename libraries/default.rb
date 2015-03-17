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
  (data['databases'] || Hash.new).each do | name, database |
    mo_application_database database['name'] do
      username database['username']
      password database['password']
      application_servers data['application_servers']
      action :remove if database['remove']
    end
  end
end


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
  return if data['remove']
  if data['user'] && data['databases'] 
    _,db = data['databases'] && data['databases'].first
    if db
      template "users database conf for #{data['user']}" do
        path lazy { ::File.join(::Dir.home(data['user']),".my.cnf" ) }
        owner data['user']
        source 'my.cnf.erb'
        cookbook 'mo_application'
        variables(username: db['username'] || db['name'],
                  password: db['password'],
                  host: db['host'] || 'localhost')
      end
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

def mo_application_backup_from_databag(cookbook_name)
  mo_application_from_data_bag(cookbook_name, false).tap do |data|
    mo_application_backup data
  end
end

def mo_application_sync_from_databag(cookbook_name)
  mo_application_from_data_bag(cookbook_name, false).tap do |data|
    mo_application_sync data
  end
end

def mo_application_backup(data)
  data['backup'] ||= Hash.new
  data['backup']['user'] ||= backup_default_user(data)
  data['backup']['archives'] ||= backup_shared_archives(data)
  data['backup']['databases'] ||= backup_databases(data)
  data['backup']['storages'] ||= backup_default_storages
  data['backup']['notifiers'] ||= backup_default_notifiers

  backup_name = "#{node['fqdn']}-#{data['id']}"

  mo_backup backup_name do
    archives  data['backup']['archives']
    databases data['backup']['databases']
    storages  data['backup']['storages']
    notifiers data['backup']['notifiers']
    user data['backup']['user']
    action (data['remove'] ? :remove : :create)
  end
end

def mo_application_sync(data)
  data['backup'] ||= Hash.new
  dirs = backup_sync_directories(data)
  data['backup']['user'] ||= backup_default_user(data)
  data['backup']['syncers'] ||= backup_default_syncers
  data['backup']['notifiers'] ||= backup_default_notifiers

  backup_name = "#{node['fqdn']}-#{data['id']}"

  mo_backup_sync backup_name do
    prefix_path   backup_name
    directories   dirs
    every_minutes data['backup']['sync']['every_minutes']
    every_hours   data['backup']['sync']['every_hours']
    syncers       data['backup']['syncers']
    notifiers     data['backup']['notifiers']
    user          data['backup']['user']
    action (data['remove'] ? :remove : :create)
  end
end

# Prefix each directory with base path and shared directory
def backup_sync_directories(data)
  directories = data['backup']['sync']['directories']
  directories.map {|dir| ::File.join data['path'],'app','shared',dir }
end

def backup_shared_archives(data)
  [].tap do |archives|
    archives << ::File.join(data['path'],'log')
    (data['shared_dirs'] || Hash.new).each do |shared_dir,_|
      archives << ::File.join(data['path'],'app','shared', shared_dir)
    end
  end
end

def backup_default_user(data)
  data['backup']['user'] || node['mo_application']['backup']['user']
end

# Return databases hash changing user&pass to make backups. This is because backups need special
# privileges
def backup_databases(data)
  data['databases'].each do |name, db_data|
    raise "DB Type is not specified at #{name}." unless db_data['type']
    db_data['username'] = db_data['backup_username'] || node['mo_application']['backup']['database'][db_data['type']]['username']
    db_data['password'] = db_data['backup_password'] || node['mo_application']['backup']['database'][db_data['type']]['password']
    db_data['additional_options'] ||= node['mo_application']['backup']['database'][db_data['type']]['additional_options']
  end
end

def backup_default_storages
  {}.tap do |storages|
    node['mo_application']['backup']['storages'].each do |storage|
      storages[storage] = encrypted_data_bag_item(node['mo_application']['backup']['storages_databag'], storage)
    end
  end
end

def backup_default_syncers
  {}.tap do |syncers|
    node['mo_application']['backup']['syncers'].each do |syncer|
      syncers[syncer] = encrypted_data_bag_item(node['mo_application']['backup']['syncers_databag'], syncer)
    end
  end
end

def backup_default_notifiers
  {}.tap do |notifiers|
    node['mo_application']['backup']['notifiers'].each do |notifier|
      notifiers[notifier] = encrypted_data_bag_item(node['mo_application']['backup']['notifiers_databag'], notifier)
    end
  end
end

