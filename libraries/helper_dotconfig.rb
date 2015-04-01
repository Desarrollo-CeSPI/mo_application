def dotconfig(data)
  return if data['remove']

  if data['user'] && data['databases']
    _,db = data['databases'] && data['databases'].first
    if db
      mo_database_set_superuser_info db
      template "users database conf for #{data['user']}" do
        path lazy { ::File.join(::Dir.home(data['user']),".my.cnf" ) }
        owner data['user']
        source 'my.cnf.erb'
        cookbook 'mo_application'
        variables(username: db['username'] || db['name'],
                  password: db['password'],
                  host: db['host'] || 'localhost')
      end
    end
  end
end
