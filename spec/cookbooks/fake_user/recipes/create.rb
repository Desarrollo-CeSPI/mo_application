mo_application_user 'user_default'

mo_application_user 'user_group' do
  group 'some_group'
end

mo_application_user 'temporary_home' do
  home '/tmp/temporary_home'
end

mo_application_user 'dont_like_bash' do
  shell '/bin/sh'
end
