actions :create
default_action :create

attribute :superuser, :kind_of => String, :default => 'root'
attribute :superuser_password, :kind_of => String
attribute :superuser_host, :kind_of => String, :default => 'localhost'
attribute :name, :kind_of => String, :name_attribute => true
attribute :host, :kind_of => [Array,String], :default => 'localhost'
attribute :username, :kind_of => String
attribute :password, :kind_of => String, :required => true

def initialize(name, run_context=nil)
  super
  @superuser_password = run_context && run_context.node['mysql']['server_root_password']
  @username = name
end
