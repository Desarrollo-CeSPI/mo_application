class MoApplication
  module Nginx

    def self.included(klass)
      klass.send :attr_accessor, :www_logs
    end

    def nginx_pid
      node['nginx']['pid']
    end

    def www_user
      node['nginx']['user']
    end

    def www_group
      node['nginx']['group']
    end

    def www_log_dir
      ::File.join(new_resource.path,'log','nginx')
    end

    def www_access_log(name)
      ::File.join(www_log_dir, "#{name}-access.log")
    end

    def www_error_log(name)
      ::File.join(www_log_dir, "#{name}-error.log")
    end

    def nginx_document_root(relative_path)
      ::File.join(application_current_path, relative_path)
    end

    def nginx_options_for(action, name, options)
      {
        "action"    => action,
        "listen"    => "80",
        "locations" => {
          %q(/) => {
            "try_files"     => "$uri $uri/",
          },
          %q(~* \.(jpg|jpeg|gif|html|png|css|js|ico|txt|xml)$) => {
            "access_log"    => "off",
            "log_not_found" => "off",
            "expires"       => "365d"
          },
        },
        "options" => {
          "index"       => "index.php index.html index.htm",
          "access_log"  => www_access_log(name),
          "error_log"   => www_error_log(name)
        },
        "root"      => nginx_document_root(options['relative_document_root']),
        "site_type" => "dynamic"
      }
    end

    def nginx_create_configuration
      nginx_configuration :create
    end

    def nginx_remove_configuration
      nginx_configuration :delete
    end

    def nginx_application_name(name)
      "#{new_resource.name}_#{name}"
    end

    def nginx_configuration(template_action=:create)
      self.www_logs = Array(self.www_logs)
      new_resource.nginx_config.each do |app_name,options|
        name = nginx_application_name app_name

        conf = nginx_options_for(template_action, app_name , options).merge(options)

        self.www_logs << conf["options"]["access_log"] if conf["options"] && conf["options"]["access_log"]
        self.www_logs << conf["options"]["error_log"] if conf["options"] && conf["options"]["error_log"]

        node.set['mo_application']['server_names'] = (node['mo_application']['server_names'] + [ conf['server_name'] ]).uniq
        node.save unless Chef::Config[:solo]

        hostsfile_entry node.ipaddress do
          hostname  node.fqdn
          aliases   node['mo_application']['server_names']
          action    :create
        end

        service 'nginx' do
          action   :nothing
        end

        nginx_conf_file "#{name}.conf" do
          action conf['action']
          block conf['block']
          cookbook conf['cookbook']
          listen conf['listen']
          locations conf['locations']
          options conf['options']
          upstream conf['upstream']
          reload conf['reload']
          root conf['root']
          server_name conf['server_name']
          conf_name conf['conf_name']
          socket conf['socket']
          template conf['template']
          auto_enable_site conf['auto_enable_site']
          ssl conf['ssl']
          precedence conf['precedence']
          site_type conf['site_type'].to_sym if conf['site_type']
        end
      end
    end
  end
end
