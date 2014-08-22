use_inline_resources

CHROOT_DIRECTORIES = %w(dev etc lib lib64 log run usr/lib usr/share tmp var)

# Support whyrun
def whyrun_supported?
   true
end

# Load current resource set defaults for some unsetted attributes
def load_current_resource
  @current_resource ||= Chef::Resource::CespiApplicationDeploy.new(@new_resource.name)
end

# Installs an application
action :create do
  converge_by("Create #{ @new_resource }") do
    create
  end
end

# Removes an application
action :remove do
  converge_by("Remove #{ @new_resource }") do
    remove
  end
end

private

def create
  create_directories
end

def create_directories
  CHROOT_DIRECTORIES.each do |dir|
    directory ::File.join(new_resource.path, dir) do
      recursive true
    end
  end
end

def remove
  remove_directories
end

# Removes application base directory and every subdirectory inside it.
def remove_directories
  directory new_resource.path do
    recursive true
    action :delete
  end
end

