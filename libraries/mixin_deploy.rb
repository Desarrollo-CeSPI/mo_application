class MoApplication
  module DeployResourceBase
    def self.included(klass)
      # User needs
      klass.attribute :home, :kind_of => [String, NilClass], :default => nil
      klass.attribute :shell, :kind_of => String, :default => "/bin/bash"
      klass.attribute :ssh_keys, :kind_of => Array, :default => []

      # Deploy needs
      klass.attribute :description, :kind_of => String
      klass.attribute :path, :kind_of => String, required: true
      klass.attribute :name, :kind_of => String, :name_attribute => true
      klass.attribute :deploy, :kind_of => [TrueClass, FalseClass], :default => true
      klass.attribute :user, :kind_of => [String, NilClass], :default => nil
      klass.attribute :group, :kind_of => [String, NilClass], :default => nil
      klass.attribute :relative_path, :kind_of => String, :default => 'app'
      klass.attribute :repo, :kind_of => String
      klass.attribute :revision, :kind_of => [String], :default => "HEAD"
      klass.attribute :migrate, :kind_of => [TrueClass, FalseClass], :default => true
      klass.attribute :migration_command, :kind_of => [String, NilClass]
      klass.attribute :shared_dirs, :kind_of => Hash, :default => Hash.new
      klass.attribute :shared_files, :kind_of => Hash, :default => Hash.new
      klass.attribute :create_dirs_before_symlink, :kind_of => Array, :default => []
      klass.attribute :force_deploy, :kind_of => [TrueClass,FalseClass], :default => false
      klass.attribute :ssh_wrapper, :kind_of => String
      klass.attribute :ssh_key_name, :kind_of => String, :default => 'deploy'
      klass.attribute :ssh_private_key, :kind_of => String
      klass.attribute :environment, :kind_of => Hash, :default => Hash.new
      klass.attribute :before_migrate, :kind_of => [Proc, String]
      klass.attribute :before_restart, :kind_of => [Proc, String]
      klass.attribute :restart_command, :kind_of => [Proc, String]
      klass.attribute :before_symlink, :kind_of => [Proc, String]
      klass.attribute :before_deploy, :kind_of => [Proc, String]
      klass.attribute :services, :kind_of => Hash, :default => Hash.new

      klass.attribute :log_dir, :kind_of => String, :default => 'log'

      # Nginx configurations: must define a hash of:
      #   * key is vhost file name, it will namespaced with mo_application name attribute
      #   * value of nginx options. Most values can be overwritten. 
      #     Custom options are:
      #     + relative_document_root: as deploy resource will create a current symlink, then specified path
      #       for this option must be a relative project path: by default we asume it is web/
      klass.attribute :nginx_config, :kind_of => Hash, :default => { 'frontend' => Hash.new }

      # Hash of environment variables to set with dotenv
      klass.attribute :dotenv, :kind_of => Hash, :default => Hash.new

    end
  end

  module DeployProviderBase
    def self.included(klass)
      klass.use_inline_resources
      klass.send :include, MoApplication::Logrotate
      klass.send :include, MoApplication::SetupSSH
      klass.send :include, MoApplication::Nginx
    end

    # Main action for providers :install action
    def install_application
      create_user

      create_directories

      setup_ssh new_resource.user, new_resource.group, new_resource.ssh_private_key, new_resource.ssh_key_name

      create_services

      add_sudo_services

      instance_eval(&new_resource.before_deploy) if new_resource.before_deploy

      create_dotenv

      configure_user_environment

      deploy_application if new_resource.deploy

      nginx_create_configuration

      logrotate_create_configuration

      links_for_user
    end

    # Main action for providers :remove action
    def uninstall_application
      remove_services

      remove_sudo_services

      nginx_remove_configuration

      logrotate_remove_configuration

      remove_directories

      remove_user
    end

    # Creates application's user
    def create_user
      user :create
    end

    # Removes application's user
    def remove_user
      user :remove
    end

    def user(to_do)
      mo_application_user new_resource.user do
        group new_resource.group
        ssh_keys new_resource.ssh_keys
        action to_do
      end
    end

    def application_shared_template(name, &block)
      template(::File.join(application_shared_path, name),&block).tap do |t|
        t.source "#{name}.erb"
        t.owner new_resource.user
        t.group www_group
      end
    end


    def  create_dotenv
      if new_resource.dotenv.any?
        file ::File.join(application_shared_path,'.env') do
          owner new_resource.user
          group www_group
          content new_resource.environment.merge(new_resource.dotenv).map {|k,v| "#{k}=#{v}"}.join("\n")
          action :create_if_missing
        end
      end
    end



    # Add convinient links for application's user to quick access to application's directory and logs
    def links_for_user
      link ::File.join('/home',new_resource.user,'application') do
        to ::File.join(application_full_path)
      end

      link ::File.join('/home',new_resource.user,'log') do
        to ::File.join(new_resource.path,'log')
      end
    end


    # Helper method that returns application path joined with relative_path
    def application_full_path
      ::File.join(new_resource.path,new_resource.relative_path)
    end

    def application_shared_path
      ::File.join(application_full_path,'shared')
    end

    def application_current_path
      ::File.join(application_full_path,'current')
    end

    # Creates application required directories to deploy into
    # Applications directory tree will be composed as capistrano or
    # Chef deploy resource expects to be:
    # /app/base_dir/
    #   + shared/
    #   + releases/
    #   + @current -> releases/xxx
    # We must create shared folder and every folder containing files to be 
    # written as templates
    def create_directories
      execute "change-permissions-#{new_resource.path}" do
        command "chown -R #{new_resource.user}:#{www_group} #{new_resource.path}"
        user "root"
        action :nothing
      end
      dirs = shared_directories.
        insert(0,new_resource.path).
        insert(1,application_full_path).
        insert(2,application_shared_path).
        insert(3,full_var_run_directory).
        insert(4,www_log_dir) + custom_dirs
      dirs.each do |dir|
        directory dir do
          owner new_resource.user
          group www_group
          mode '0750'
          recursive true
          notifies :run, "execute[change-permissions-#{new_resource.path}]"
        end
      end
    end

    # Where will pids and sockets will be saved
    def var_run_directory
      ::File.join('var','run')
    end

    def full_var_run_directory
      ::File.join(new_resource.path,var_run_directory)
    end

    # Returns every shared directory
    # This directories will be:
    #   * Every shared_files dirname
    #   * Every shared_directory
    # All this specified directories are relative to shared folder, so
    # we need to build full_path
    def shared_directories
      (
        new_resource.shared_files.map do |shared_path, _ |
          ::File.join application_shared_path, ::File.dirname(shared_path)
        end +
        new_resource.shared_dirs.map do |shared_dir, _ |
          ::File.join application_shared_path, shared_dir
        end
      ).sort.uniq
    end

    # Chef deploy resource wrapper
    def deploy_application
      deploy new_resource.name do
        provider Chef::Provider::Deploy::Revision
        deploy_to application_full_path
        repo new_resource.repo
        revision new_resource.revision
        purge_before_symlink new_resource.shared_dirs.values
        symlink_before_migrate new_resource.shared_files
        create_dirs_before_symlink new_resource.create_dirs_before_symlink
        symlinks new_resource.shared_dirs
        user new_resource.user
        group www_group
        migrate new_resource.migrate
        environment new_resource.environment
        migration_command new_resource.migration_command
        before_migrate new_resource.before_migrate
        before_restart new_resource.before_restart
        ssh_wrapper new_resource.ssh_wrapper || node['mo_application']['ssh_wrapper']
        restart_command new_resource.restart_command
        before_symlink new_resource.before_symlink
        action (new_resource.force_deploy ? :force_deploy : :deploy)
      end
    end

    # Removes application base directory and every subdirectory inside it.
    def remove_directories
      directory new_resource.path do
        recursive true
        action :delete
      end
    end


    # Add sudo service restart foreach service
    def add_sudo_services
      sudo_services :install
    end

    # Remove sudo service restart foreach service
    def remove_sudo_services
      sudo_services :remove
    end

    def sudo_services(to_do)
      commands = ["/usr/sbin/service %{service} *","/sbin/start %{service}", "/sbin/stop %{service}", "/sbin/restart %{service}"]
      commands = services_names.map {|srv| commands.map {|cmd| cmd % { :service => srv } } }.flatten
      sudo "services_#{new_resource.user}" do
        user      new_resource.user
        runas     'root'
        commands  commands
        nopasswd  true
        action to_do
      end
    end

    def logrotate_service_logs
        Array(www_logs)
    end

    def logrotate_postrotate
      <<-CMD
            [ ! -f #{nginx_pid} ] || kill -USR1 `cat #{nginx_pid}`
      CMD
    end


    ###########################################################################
    # The following methods shall be overwritten by providers that implement
    # this module
    #--------------------------------------------------------------------------

    # Which custom directories are needed to be created when deploying application
    #   For example, for a php application, a php for session files can be created
    def custom_dirs
      []
    end
    
    #Personalize shell environment using magic_shell
    def configure_user_environment; end

    # Creates upstart configuration in case of a ruby app
    def create_services
      raise 'Provider must implement how to create services'
    end

    # Must stop service when is an application like puma or unicorn app
    def remove_services
      raise 'Provider must implement how to remove services'
    end

    # Returns service names related to this application. For a php application may be an array containg only php-fpm
    # In case of a ruby application may be a hash with service name as key and command as value
    def services_names
      new_resource.services.is_a?(Hash) ? new_resource.services.keys : new_resource.services
    end

  end
end
