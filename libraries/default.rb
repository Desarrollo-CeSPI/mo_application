def mo_database(data)
  mo_application_database data['database']['name'] do
    username data['database']['username']
    password data['database']['password']
    application_servers data['database']['application_servers']
    action :remove if data['database']['remove']
  end
end
