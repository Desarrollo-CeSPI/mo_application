actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :host, :kind_of => String, :required => true
attribute :username, :kind_of => String, :required => true
attribute :password, :kind_of => String, :required => true
