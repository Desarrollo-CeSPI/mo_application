actions :install, :remove
default_action :install

include MoApplication::DeployResourceBase

def initialize(name, run_context=nil)
  super
  @user = name
  @group = name
end


