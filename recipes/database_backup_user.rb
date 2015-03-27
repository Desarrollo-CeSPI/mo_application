include_recipe "database::mysql"

mysql_connection_info = {username: 'root', password: node['mysql']['server_root_password'] }

mysql_database_user node['mo_application']['backup']['database']['mysql']['username'] do
    connection mysql_connection_info
    password node['mo_application']['backup']['database']['mysql']['password']
    host '%'
    privileges [:reload ]
    action [:create, :grant]
end

mysql_database_user node['mo_application']['backup']['database']['mysql']['username'] do
    connection mysql_connection_info
    password node['mo_application']['backup']['database']['mysql']['password']
    host '%'
    privileges [:all ]
    action [:grant]
end
