actions :create, :remove
default_action :create

attribute :superuser, :kind_of => String, :default => 'root'
attribute :superuser_password, :kind_of => String
attribute :superuser_host, :kind_of => String, :default => '127.0.0.1'
attribute :name, :kind_of => String, :name_attribute => true
attribute :application_servers, :kind_of => Array, :default => ['127.0.0.1']
attribute :username, :kind_of => String
attribute :password, :kind_of => String, :required => true

def initialize(name, run_context=nil)
  super
  @superuser_password = run_context && run_context.node['mysql']['server_root_password']
  @username = name
end
