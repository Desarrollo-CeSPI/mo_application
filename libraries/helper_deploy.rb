def mo_application_documentation(data)
  return if data['remove']
  template ::File.join('/home', data['user'], 'README') do
    owner data['user']
    cookbook 'mo_application'
    variables(
      name: data['id'],
      user: data['user'],
      group: data['group'],
      application_path: ::File.join('$HOME','application'),
      logs_path: ::File.join('$HOME','log'),
      description: data['description'],
      applications: data['applications'],
      environment:  data['environment'],
      additional_doc: ::File.join('$HOME','doc')
    )
    source 'README.erb'
  end

  directory ::File.join('/home', data['user'], 'doc') do
    owner data['user']
  end

  template ::File.join('/home', data['user'], 'doc', 'DATABASES') do
    owner data['user']
    cookbook 'mo_application'
    source 'README-databases.erb'
    variables(databases: data['databases'])
    only_if { data['databases'] }
  end

end

def mo_application_deploy(data, resource, &before_deploy_block)
  # Create a new resource named as data['id']
  r = send resource, data['id'] do
    #User to install application as
    user data['user']
    #Group of user to install application as
    group data['group']
    # User home and shell wont be overwrittem
    #
    # List of ssh keys allowed to connect as user
    ssh_keys data['ssh_keys']

    description data['description']

    #Application will be deployed at path/relative_path. If not specified, 
    #default "app" will be used
    path data['path']
    relative_path data['relative_path']
    # Application custom logs. By default we set log
    log_dir data['log_dir']

    # SCM repo & revision from where to download code from
    repo data['repo']
    revision data['revision']

    # Run migration command??? defaults to true
    if data['migration_command'].nil? || data['migration_command'] == ''
      migrate false
    else
      migrate data['migrate']
    end
    migration_command (data['migration_command'] || '')

    # Deploy application?? If not nothing will be done relative to download code and run migrations
    deploy data['deploy']
    # Force deploy will always download and run migrations. Every chef run
    force_deploy data['force_deploy']
    # ssh private key used by SCM to retrieve code from private repos
    ssh_private_key data['ssh_private_key']
    # Custom environment variables used to run migrations and start service
    environment data['environment']
    # Shared files
    shared_files data['shared_files']
    # Shared directories
    shared_dirs data['shared_dirs']

    # Restart command to run after deployment
    restart_command data['restart_command']

    # An application may create multiple services, each one with specific commands.
    # This is a hash with service name as key and command as value or an array of service names
    services data['services']

    # Block of code to run before deploying application
    before_deploy before_deploy_block
    # Block of code or string of template with ruby code to run before running migrations
    before_migrate data['before_migrate']
    # Block of code or string of template with ruby code to run before restarting application
    before_restart data['before_restart']
    # Block of code or string of template with ruby code to run before creating symlinks
    before_symlink data['before_symlink']

    # For each virtual host, we can set specific options taht will be merged with custom options
    nginx_config data['applications']

    # Create dotenv file
    dotenv data['dotenv']

    # When is a ruby resource, we can also specify
    if resource.to_s =~ /ruby/
      # Force gems update by removing bundle path and regenerating it
      update_gems data['update_gems']

      # Force the use of specified number of jobs to run bundle install
      bundle_install_jobs data['bundle_install_jobs']

      ruby_version data['ruby_version']
      # Name of wich Bundler groups to ignore: development and test
      bundle_without_groups data['bundle_without_groups']
    elsif resource.to_s =~ /php/
      # PHP FPM configuration
      php_fpm_config data['php_fpm_config']
    end

    action (data['remove'] ? :remove : :install)
  end

  #When resource is created, we try to configure and setup some dot configurations
  dotconfig data

  mo_application_documentation data

  if data['remove']
    node.set["deployed_applications"] = Array(node["deployed_applications"]) - [data["id"]]
  else
    node.set["deployed_applications"] = (Array(node["deployed_applications"]) + [data["id"]]).uniq
  end
  r
end

