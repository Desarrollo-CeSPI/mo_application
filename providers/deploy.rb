use_inline_resources

action :install do
  create_user
  create_directories
  if new_resource.callbacks[:before_deploy].respond_to?(:call)
    instance_eval(&new_resource.callbacks[:before_deploy])
  end
  deploy
end


def load_current_resource
  @current_resource = Chef::Resource::CespiApplicationDeploy.new(@new_resource.name)
end

def initialize(new_resource, run_context)
  new_resource.user new_resource.name unless new_resource.user
  new_resource.group new_resource.user unless new_resource.group
  new_resource.home "/home/#{new_resource.user}" unless new_resource.home
  super(new_resource, run_context)
end


private
def create_user
  new_resource = @new_resource

  group new_resource.group

  user new_resource.user do
    supports :manage_home => true
    home new_resource.home
    gid new_resource.group
    shell new_resource.shell
  end
end

def create_directories
  new_resource = @new_resource
  shared_directories.
    insert(0,new_resource.path).
    insert(1,"#{new_resource.path}/shared").
    each {|dir| create_directory dir }
end

def shared_directories
  dirs = @new_resource.shared_files.map do |shared_path, _ |
    ::File.join @new_resource.path,'shared', ::File.dirname(shared_path)
  end
  (dirs + @new_resource.shared_dirs.map do |shared_dir, _ |
    ::File.join @new_resource.path,'shared', shared_dir
  end).sort.uniq
end

def create_directory(dir)
  new_resource = @new_resource
  directory dir do 
    recursive true
    owner new_resource.user
    group new_resource.group
  end
end

def deploy(s_action = :deploy)
  new_resource = @new_resource
  deploy_revision new_resource.name do
    deploy_to new_resource.path
    repo new_resource.repo
    revision new_resource.revision
    purge_before_symlink new_resource.shared_dirs.values
    create_dirs_before_symlink new_resource.shared_dirs.keys
    symlink_before_migrate new_resource.shared_files
    symlinks new_resource.shared_dirs
    user new_resource.user
    group new_resource.group
    migrate new_resource.migrate
    migration_command new_resource.migration_command
    action s_action
  end
end
