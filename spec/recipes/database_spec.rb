require_relative '../spec_helper'

describe 'fake_database::create'do
  let(:mysql_super_password) { 'sakjdhi12' }
  # Use an explicit subject
  let(:chef_run) do
    chef_run_lwrp(:mo_application_database) do |node|
      node.set['mysql']['server_root_password'] = mysql_super_password
    end.converge(described_recipe)
  end

  let(:default_connection) {Hash[host: 'localhost', username: 'root', password: mysql_super_password]}

  it 'set defaults' do
    expect(chef_run).to create_mysql_database('defaults').with(
      connection: default_connection
    )
    expect(chef_run).to create_mysql_database_user('defaults_localhost').with(
      connection: default_connection,
      username: 'defaults',
      password: 'defaults_pass',
      database_name: 'defaults',
      host: 'localhost'
    )
    expect(chef_run).to grant_mysql_database_user('defaults_localhost').with(
      connection: default_connection,
      username: 'defaults',
      database_name: 'defaults',
      host: 'localhost'
    )
  end

  let(:priviliged_connection) {Hash[host: 'dbsuper_host', username: 'dbsuper', password: 'dbsuper_password']}

  it 'uses specified params' do

    expect(chef_run).to create_mysql_database('dbname').with(
      connection: priviliged_connection
    )
    expect(chef_run).to create_mysql_database_user('dbusername_dbhost').with(
      connection: priviliged_connection,
      password: 'defaults_pass',
      database_name: 'dbname',
      host: 'dbhost',
      username: 'dbusername',
      password: 'dbpassword'
    )
    expect(chef_run).to grant_mysql_database_user('dbusername_dbhost').with(
      connection: priviliged_connection,
      host: 'dbhost',
      database_name: 'dbname',
      host: 'dbhost',
      username: 'dbusername',
    )
  end

  it 'considers multiple hosts' do
    expect(chef_run).to create_mysql_database('multihost').with(
      connection: default_connection,
    )
    %w(db1 db2).each do |db|
      expect(chef_run).to create_mysql_database_user("multihost_#{db}").with(
        connection: default_connection,
        username: 'multihost',
        password: 'defaults_pass',
        database_name: 'multihost',
        host: db
      )
      expect(chef_run).to grant_mysql_database_user("multihost_#{db}").with(
        connection: default_connection,
        username: 'multihost',
        database_name: 'multihost',
        host: db
      )
    end
  end

end
