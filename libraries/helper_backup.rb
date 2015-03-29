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
  data['backup']['exclude_databases'] ||= []
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
  (data['databases'] || Hash.new).dup.tap do |new_db|
    data['backup']['exclude_databases'].each do |k|
      new_db.delete k
    end
    new_db.each do |name, db_data|
      raise "DB Type is not specified at #{name}." unless db_data['type']
      db_data['username'] = db_data['backup_username'] || node['mo_application']['backup']['database'][db_data['type']]['username']
      db_data['password'] = db_data['backup_password'] || node['mo_application']['backup']['database'][db_data['type']]['password']
      db_data['additional_options'] ||= node['mo_application']['backup']['database'][db_data['type']]['additional_options']
    end
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
