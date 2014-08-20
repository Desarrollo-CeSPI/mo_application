actions :install, :remove
default_action :install

attribute :name, :kind_of => String, :name_attribute => true
attribute :user, :kind_of => [String, NilClass], :default => (lazy {|r|r.name})
attribute :group, :kind_of => [String, NilClass], :default => (lazy {|r|r.user})
attribute :home, :kind_of => [String, NilClass], :default => (lazy {|r| "/home/#{r.user}"})
attribute :shell, :kind_of => String, :default => "/bin/bash"
attribute :path, :kind_of => String, :required => true
attribute :repo, :kind_of => String, :required => true
attribute :revision, :kind_of => [String], :default => "HEAD"
attribute :migrate, :kind_of => [TrueClass, FalseClass], :default => false
attribute :migration_command, :kind_of => [String, NilClass]
attribute :shared_dirs, :kind_of => [Hash], :default => Hash.new
attribute :shared_files, :kind_of => [Hash], :default => Hash.new
attribute :force_deploy, :kind_of => [TrueClass,FalseClass], :default => false

attr_accessor :callbacks


def initialize(name, run_context=nil)
  super
  @callbacks = {}
end


def before_deploy(arg=nil, &block)
  callbacks[:before_deploy] = block
end
