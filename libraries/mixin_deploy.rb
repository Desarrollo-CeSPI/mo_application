class MoApplication
  module DeployResourceBase
    def self.included(klass)
      klass.actions :install, :remove
      klass.default_action :install

      # User needs
      klass.attribute :home, :kind_of => [String, NilClass], :default => nil
      klass.attribute :shell, :kind_of => String, :default => "/bin/bash"
      klass.attribute :ssh_keys, :kind_of => Array, :default => []

      # Deploy needs
      klass.attribute :name, :kind_of => String, :name_attribute => true
      klass.attribute :deploy, :kind_of => [TrueClass, FalseClass], :default => true
      klass.attribute :user, :kind_of => [String, NilClass], :default => nil
      klass.attribute :group, :kind_of => [String, NilClass], :default => nil
      klass.attribute :relative_path, :kind_of => String, :default => 'app'
      klass.attribute :repo, :kind_of => String
      klass.attribute :revision, :kind_of => [String], :default => "HEAD"
      klass.attribute :migrate, :kind_of => [TrueClass, FalseClass], :default => false
      klass.attribute :migration_command, :kind_of => [String, NilClass]
      klass.attribute :shared_dirs, :kind_of => Hash, :default => Hash.new
      klass.attribute :shared_files, :kind_of => Hash, :default => Hash.new
      klass.attribute :create_dirs_before_symlink, :kind_of => Array, :default => []
      klass.attribute :force_deploy, :kind_of => [TrueClass,FalseClass], :default => false
      klass.attribute :ssh_wrapper, :kind_of => String
      klass.attribute :ssh_private_key, :kind_of => String


      klass.attribute :log_dir, :kind_of => String, :default => 'log'

      # Nginx configurations: must define a hash of:
      #   * key is vhost file name, it will namespaced with mo_application name attribute
      #   * value of nginx options. Most values can be overwritten. 
      #     Custom options are:
      #     + relative_document_root: as deploy resource will create a current symlink, then specified path
      #       for this option must be a relative project path: by default we asume it is web/
      klass.attribute :nginx_config, :kind_of => Hash, :default => { 'frontend' => Hash.new }

      klass.send :attr_reader, :callback_before_deploy
    end

    def before_deploy(&block)
      @callback_before_deploy= block
    end

  end
end