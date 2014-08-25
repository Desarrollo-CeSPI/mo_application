require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

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

def copy_files
  (new_resource.copy_files.is_a?(String) ? new_resource.copy_files.split(',') : new_resource.copy_files).
    map do |app|
      cmd = shell_out("ldd #{app}")
      # If can't retrieve ldd, then output app
      cmd.error? ? app : cmd.stdout.split.grep(/^\//)
  end.flatten.sort.uniq
end

def copy_dirs
  copy_files.map{|x| ::File.dirname x}.sort.uniq
end

def chroot_dirs
  (copy_dirs + %w(/dev /etc /log /run /tmp /var)).sort.uniq
end


def create
  chroot_dirs.
    each do |dir|
      directory ::File.join(new_resource.path, dir) do
        recursive true
      end
  end
  copy
end

def remove
  directory new_resource.path do
    recursive true
    action :delete
  end
end

def copy
  copy_files.each do |file|
    ruby_block "copy file #{file}" do
      block { shell_out! "cp -aL #{file} #{::File.join new_resource.path, file}" }
      not_if "test -e #{::File.join new_resource.path, file}"
    end
  end
end

