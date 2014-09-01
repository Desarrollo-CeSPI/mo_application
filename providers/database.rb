use_inline_resources

# Support whyrun
def whyrun_supported?
   true
end

# Create a database and grants privileges to it
action :create do
  converge_by("Create #{ @new_resource }") do
    create_database
    grant_privileges
  end
end

# Grants privileges to the specified database
action :grant do
  converge_by("Grants privileges to #{ @new_resource }") do
    grant_privileges
  end
end


private

# Establish a new connection to the database
def db_connection
  @db_connection ||= {:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']}
end

def create_database
  connection_info = db_connection
  mysql_database new_resource.name do
    connection connection_info
    action :create
  end
end

def grant_privileges
  connection_info = db_connection
  mysql_database_user new_resource.username do
    connection connection_info
    password new_resource.password
    host new_resource.host
    action [:create, :grant]
  end
end
