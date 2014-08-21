use_inline_resources

# Support whyrun
def whyrun_supported?
   true
end

# Load current resource set defaults for some unsetted attributes
def load_current_resource
  @current_resource ||= Chef::Resource::CespiApplicationDeploy.new(@new_resource.name)
end

# Installs an application
action :install do
  converge_by("Install #{ @new_resource }") do
    install
  end
end

def new_resource_user
  new_resource.user || new_resource.name
end

def new_resource_home
  new_resource.home || "/home/#{new_resource_user}"
end

def new_resource_group
  new_resource.group || new_resource_user
end

# Removes an application
action :remove do
  converge_by("Remove #{ @new_resource }") do
    remove
  end
end

private

def install
  create_user
  create_directories
  callback :before_deploy
  deploy_application
end

# Creates group & user
def create_user
  group new_resource_group
  user new_resource_user do
    supports :manage_home => true
    home new_resource_home
    gid new_resource_group
    shell new_resource.shell
  end
end

# Creates application required directories to deploy into
# Applications directory tree will be composed as capistrano or
# Chef deploy resource expects to be:
# /app/base_dir/
#   + shared/
#   + releases/
#   + @current -> releases/xxx
# We must create shared folder and every folder containing files to be 
# written as templates
def create_directories
  shared_directories.
    insert(0,new_resource.path).
    insert(1,"#{new_resource.path}/shared").
    each {|dir| create_directory dir }
end

# Returns every shared directory
# This directories will be:
#   * Every shared_files dirname
#   * Every shared_directory
# All this specified directories are relative to shared folder, so
# we need to build full_path
def shared_directories
  (
    new_resource.shared_files.map do |shared_path, _ |
      ::File.join new_resource.path,'shared', ::File.dirname(shared_path)
    end +
    new_resource.shared_dirs.map do |shared_dir, _ |
      ::File.join new_resource.path,'shared', shared_dir
    end
  ).sort.uniq
end

# Helper to create directories with needed permissions
def create_directory(dir)
  directory dir do
    recursive true
    owner new_resource_user
    group new_resource_group
  end
end

# If there is a callback setted for name, then call it
def callback(name)
  if new_resource.callbacks[name].respond_to?(:call)
    instance_eval(&new_resource.callbacks[name])
  end
end

# Chef deploy resource wrapper
def deploy_application
  deploy new_resource.name do
    provider Chef::Provider::Deploy::Revision
    deploy_to new_resource.path
    repo new_resource.repo
    revision new_resource.revision
    purge_before_symlink new_resource.shared_dirs.values
    create_dirs_before_symlink new_resource.shared_dirs.keys
    symlink_before_migrate new_resource.shared_files
    symlinks new_resource.shared_dirs
    user new_resource_user
    group new_resource_group
    migrate new_resource.migrate
    migration_command new_resource.migration_command
    action (new_resource.force_deploy ? :force_deploy : :deploy)
  end
end

def remove
  #callback :before_remove
  remove_user
  remove_directories
end

# Deletes group & user
def remove_user
  user new_resource.user do
    action :remove
  end

  group new_resource.group do
    action :remove
  end
end

# Removes application base directory and every subdirectory inside it.
def remove_directories
  directory new_resource.home do
    recursive true
    action :delete
  end

  directory new_resource.path do
    recursive true
    action :delete
  end
end

