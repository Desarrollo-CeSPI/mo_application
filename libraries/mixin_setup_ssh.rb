class MoApplication
  module SetupSSH

    def setup_ssh
      directory "/home/#{new_resource.user}/.ssh" do
        action :create
        owner new_resource.user
        group new_resource.group
        recursive true
      end

      file "/home/#{new_resource.user}/.ssh/id_rsa" do
        content new_resource.ssh_private_key
        owner new_resource.user
        mode 0600
      end
    end
  end
end

