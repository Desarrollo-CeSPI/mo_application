def cespi_database(data)
  cespi_application_database data['database']['name'] do
    username data['database']['username']
    password data['database']['password']
    application_servers data['database']['application_servers']
  end
end
