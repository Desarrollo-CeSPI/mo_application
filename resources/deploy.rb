actions :install, :remove
default_action :install

attribute :name, :kind_of => String, :name_attribute => true
attribute :user, :kind_of => [String, NilClass], :default => nil
attribute :group, :kind_of => [String, NilClass], :default => nil
attribute :path, :kind_of => String, :required => true
attribute :repo, :kind_of => String, :required => true
attribute :revision, :kind_of => [String], :default => "HEAD"
attribute :migrate, :kind_of => [TrueClass, FalseClass], :default => false
attribute :migration_command, :kind_of => [String, NilClass]
attribute :shared_dirs, :kind_of => Hash, :default => Hash.new
attribute :shared_files, :kind_of => Hash, :default => Hash.new
attribute :create_dirs_before_symlink, :kind_of => Array, :default => []
attribute :force_deploy, :kind_of => [TrueClass,FalseClass], :default => false
attribute :log_dir, :kind_of => String, :default => 'log'
attribute :ssh_wrapper, :kind_of => String

attr_reader :callback_before_deploy


def before_deploy(&block)
  @callback_before_deploy = block
end

def initialize(name, run_context=nil)
  super
  @user = name
  @group = name
end


