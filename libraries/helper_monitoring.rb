require 'uri'

def mo_application_http_expected_codes
  "200,401,301,302"
end

def mo_application_http_check(data)
  return unless data['applications']
  (data['applications'] || Hash.new).each do |k, vhost_data|
    server_name = URI(application_url(vhost_data)).host
    extra_arguments = vhost_data['monitoring'] && vhost_data['monitoring']['http_check'] ? vhost_data['monitoring']['http_check'] : ''
    check_name = "check-http-app-server_#{data['id']}_#{k}"
    nrpe_check check_name do
      command "#{node['nrpe']['plugin_dir']}/check_http"
      parameters "-e #{mo_application_http_expected_codes} -I #{node.ipaddress} -H #{server_name} #{extra_arguments}"
      notifies :restart, "service[#{node['nrpe']['service_name']}]"
      action (data['remove'] ? :remove : :add)
    end
  end
end

def mo_application_custom_monitoring_check_script
 File.join node["mo_monitoring_client"]["install_directory"], node['mo_application']['monitoring']['custom_check']
end

def mo_application_custom_check(data, default_env = {})
  return unless data['monitoring']
  return unless data['monitoring']['custom']
  check_name = "check-custom-app_#{data['id']}"
  environment = (data['environment'] || default_env).map {|k,v| "#{k}=#{v}"}.join ' '
  nrpe_check check_name do
    command "sudo -Hu #{data['user']} #{environment} #{mo_application_custom_monitoring_check_script} #{data['monitoring']['custom']}"
    notifies :restart, "service[#{node['nrpe']['service_name']}]"
    action (data['remove'] ? :remove : :add)
  end
end
