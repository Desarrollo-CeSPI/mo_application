class CespiApplication
  module Logrotate

    def application_logs
      ::File.join(new_resource.path, 'shared', new_resource.log_dir, '*.log')
    end

    def logrotate(enable_flag = true)
      include_recipe "logrotate"
      logrotate_app new_resource.name do
        path application_logs
        options ['missingok', 'delaycompress', 'notifempty']
        frequency 'weekly'
        maxsize   '1M'
        rotate    10
        create    %W(644 #{new_resource.user} #{new_resource.group}).join
        enable enable_flag
      end
    end

  end
end
