cespi_application_database 'defaults' do
  password 'defaults_pass'
end

cespi_application_database 'with_different_params' do
  superuser 'dbsuper'
  superuser_password 'dbsuper_password'
  name 'dbname'
  host 'dbhost'
  username 'dbusername'
  password 'dbpassword'
end

