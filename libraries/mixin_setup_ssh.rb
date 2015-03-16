class MoApplication
  module SetupSSH

    def setup_ssh(user, group, ssh_private_key, key_name="id_rsa")
      directory "directory .ssh for #{user}" do
        path lazy { ::File.join(::Dir.home(user),".ssh") }
        action :create
        owner user
        group group
        recursive true
      end

      file "path to private key for #{user}" do
        path lazy { ::File.join(::Dir.home(user),".ssh",key_name) }
        content ssh_private_key
        owner user
        mode 0600
      end
    end
  end

end
