class CespiApplication
  module Logrotate

    def logrotate_service_logs
      []
    end

    def logrotate_application_logs
      ::File.join(new_resource.path, 'shared', new_resource.log_dir, '*.log')
    end

    def logrotate_permissions
      %W(644 #{new_resource.user} #{new_resource.group}).join ' '
    end

    def logrotate_options
      %w(missingok delaycompress notifempty compress sharedscripts)
    end

    def logrotate_postrotate
      nil
    end

    def logrotate(enable_flag = true)
      run_context.include_recipe "logrotate"
      self.tap do |me|
        logrotate_app "cespi-application-services-#{new_resource.name}" do
          path me.logrotate_service_logs
          options me.logrotate_options
          frequency 'weekly'
          minsize   '1M'
          rotate    10
          create me.logrotate_permissions
          postrotate me.logrotate_postrotate if me.logrotate_postrotate
          enable enable_flag
        end unless logrotate_service_logs.empty?

        logrotate_app "cespi-application-#{new_resource.name}" do
          path me.logrotate_application_logs
          options me.logrotate_options
          frequency 'weekly'
          maxsize   '1M'
          rotate    10
          create me.logrotate_permissions
          enable enable_flag
        end
      end
    end

  end
end
