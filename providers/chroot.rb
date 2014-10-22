require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

use_inline_resources


# Support whyrun
def whyrun_supported?
   true
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

def copy_etc_files
  %w(
      /etc/hosts
      /etc/resolv.conf
      /etc/services)
end

def copy_files
  ((new_resource.copy_files.is_a?(String) ? new_resource.copy_files.split(',') : new_resource.copy_files) +
   copy_etc_files).
    map do |app|
      cmd = shell_out("ldd #{app}")
      # If can't retrieve ldd, then output app
      [app] +  (cmd.error? ? [] : cmd.stdout.split.grep(/^\//))
  end.flatten.sort.uniq
end

def copy_dirs
  copy_files.map{|x| ::File.dirname x}.sort.uniq
end

def nscd_dir
  '/run/nscd'
end

def mysql_dir
  '/run/mysqld'
end

def chroot_dirs
  (copy_dirs + %w(/dev /log /run /tmp /var) + [nscd_dir, mysql_dir]).sort.uniq
end


def create
  run_context.include_recipe 'nscd'

  chroot_dirs.
    each do |dir|
      directory ::File.join(new_resource.path, dir) do
        recursive true
        if dir == "/tmp"
          mode "1777"
        end
      end
  end

  link ::File.join(new_resource.path,'/var/run') do
    to '/run'
    only_if "test -d #{::File.join(new_resource.path,'run')}"
  end

  [nscd_dir, mysql_dir].each do |dir|

    mount ::File.join(new_resource.path, dir) do
      device  dir
      fstype  "none"
      options "bind"
      action  [:enable, :mount]
      not_if "[ ! -d #{dir} ] || ( mount | grep '#{::File.join new_resource.path, dir}')"
    end

  end

  copy
end

def remove

  [nscd_dir, mysql_dir].each do |dir|
    mount ::File.join(new_resource.path, dir) do
      device  dir
      fstype  "none"
      options "bind"
      action  [:umount, :disable]
    end
  end

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

