class MoApplication
  module SetupSSH

    def setup_ssh
      directory "/home/#{new_resource.user}/.ssh" do
        action :create
        owner new_resource.user
        group new_resource.group
        recursive true
      end

      template "/home/#{new_resource.user}/.ssh/id_rsa" do
        source "ssh_private_key.erb"
        cookbook 'mo_application_php'
        variables(
          private_key: new_resource.ssh_private_key
        )
        owner new_resource.user
        mode 0600
      end
    end
  end
end

