def mo_database(data)
  run_context.include_recipe "database::mysql"
  (data['databases'] || Hash.new).each do | name, database |
    mo_application_database database['name'] do
      username database['username']
      password database['password']
      application_servers data['application_servers']
      action :remove if database['remove']
    end
  end
end
