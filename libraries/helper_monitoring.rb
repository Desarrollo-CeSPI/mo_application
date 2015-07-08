def mo_application_http_expected_codes
  "200,401"
end

def mo_application_http_check(data)
  return unless data['applications']
  server_name = application_url data['applications']
  check_name = "check-http_#{server_name}"
  nrpe_check check_name do
    command "#{node['nrpe']['plugin_dir']}/check_http"
    parameters "-e #{mo_application_http_expected_codes} -I #{node.ipaddress} -H #{server_name_for data}"
    notifies :restart, "service[#{node['nrpe']['service_name']}]"
  end
end
