mo_application_deploy 'default_action' do
  path '/tmp/some_path'
  repo 'some repo'
end

mo_application_deploy 'with_before_deploy' do
  path '/tmp/some_other_path'
  repo 'some repo'
  before_deploy do
    template '/tmp/some.template'
    application_template 'config/databases.yml'
  end
end

mo_application_deploy 'with_shared_files_and_dirs' do
  path '/tmp/shared_test'
  repo 'some repo'
  shared_files('some_dir/config/databases.yml' => 'config/databases.yml')
  shared_dirs('other_dir/log' => 'log')
end
