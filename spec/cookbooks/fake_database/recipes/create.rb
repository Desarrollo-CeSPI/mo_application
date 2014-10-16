cespi_application_database 'defaults' do
  password 'defaults_pass'
end

cespi_application_database 'with_different_params' do
  superuser 'dbsuper'
  superuser_password 'dbsuper_password'
  superuser_host 'dbsuper_host'
  name 'dbname'
  application_servers ['dbhost']
  username 'dbusername'
  password 'dbpassword'
end

cespi_application_database 'multihost' do
  password 'defaults_pass'
  application_servers %w(db1 db2)
end
