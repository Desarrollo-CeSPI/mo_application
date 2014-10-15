include Chef::DSL::IncludeRecipe

use_inline_resources

# Support whyrun
def whyrun_supported?
   true
end

# Create a database and grants privileges to it
action :create do
  converge_by("Create #{ @new_resource }") do
    include_recipe "database::mysql"
    create_database
    grant_privileges
  end
end


private

# Establish a new connection to the database
def db_connection
  {:host => new_resource.host, :username => new_resource.superuser, :password => new_resource.superuser_password}
end

def create_database
  db_conn = db_connection
  mysql_database new_resource.name do
    connection db_conn
    action :create
  end
end

def grant_privileges
  db_conn = db_connection
  mysql_database_user new_resource.username do
    connection db_conn
    database_name new_resource.name
    password new_resource.password
    host new_resource.host
    action [:create, :grant]
  end
end
