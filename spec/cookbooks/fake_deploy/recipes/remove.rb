mo_application_deploy 'remove_app' do
  path '/tmp/some_path_to_remove'
  repo 'some repo'
  action :remove
end
