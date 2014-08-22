actions :create, :remove
default_action :create

attribute :path, :kind_of => String, :name_attribute => true
attribute :user, :kind_of => String, :required => true
attribute :group, :kind_of => String, :required => true
attribute :web_user, :kind_of => String, :default => 'root'
attribute :web_group, :kind_of => String, :default => 'root'
