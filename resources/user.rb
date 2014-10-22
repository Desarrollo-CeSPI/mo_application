actions :create, :remove
default_action :create

attribute :user, :kind_of => String, :name_attribute => true
attribute :group, :kind_of => [String, NilClass], :default => nil
attribute :home, :kind_of => [String, NilClass], :default => nil
attribute :shell, :kind_of => String, :default => "/bin/bash"
attribute :ssh_keys, :kind_of => Array, :default => []

def initialize(name, run_context=nil)
  super
  @user = name
  @group = name
  @home = "/home/#{@user}"
end
