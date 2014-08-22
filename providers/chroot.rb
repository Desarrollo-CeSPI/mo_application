use_inline_resources


# Support whyrun
def whyrun_supported?
   true
end

# Load current resource set defaults for some unsetted attributes
def load_current_resource
  @current_resource ||= Chef::Resource::CespiApplicationChroot.new(@new_resource.name)
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

def bindable_chroot_dirs
  %w(dev lib usr/lib usr/share).
    concat(x86_64? ? ['/lib64']:[])
end

def chroot_dirs
  bindable_chroot_dirs + %w(etc log tmp var run)
end


def x86_64?
  node['kernel']['machine'].include? "64"
end

def create
  chroot_dirs.
    each do |dir|
      directory ::File.join(new_resource.path, dir) do
        recursive true
      end
  end

  bind_directories [:enable, :mount]
end

def remove

  bind_directories [:umount, :disable]

  directory new_resource.path do
    recursive true
    action :delete
  end
end

def bind_directories(actions)
  bindable_chroot_dirs.
    each do |dir|
      mount ::File.join(new_resource.path,dir) do
        device ::File.join('',dir)
        fstype "none"
        options %w(bind ro)
        action actions
      end
    end
end
