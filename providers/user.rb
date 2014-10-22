use_inline_resources

# Support whyrun
def whyrun_supported?
   true
end

# Creates a user to run application
action :create do
  converge_by("Create application user #{ @new_resource }") do
    group new_resource.group
    user_account new_resource.user do
      supports :manage_home => true
      home new_resource.home
      gid new_resource.group
      shell new_resource.shell
      ssh_keys new_resource.ssh_keys
    end

  end
end

# Removes an application
action :remove do
  converge_by("Remove application user #{ @new_resource }") do
    user_account new_resource.user do
      supports :manage_home => true
      action :remove
    end

    group new_resource.group do
      action :remove
      only_if "getent group #{new_resource.group}"
    end
  end
end
