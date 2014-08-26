require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

include CespiApplication::ChrootResourceBase

def initialize(name, run_context=nil)
  super
  @copy_files = lazy { php_fpm_required_files }
  @provider = lookup_provider_constant :cespi_application_chroot
end

# php requirements for php-fpm chroot are:
#   * php-cli required files
#   * php extensions_dir libraries
#   * /dev/null /dev/urandom /dev/zero
def php_fpm_required_files
  [].tap do |arr|
    php_extension_dir = shell_out!("php -r 'echo ini_get(\"extension_dir\");'").stdout
    Chef::Application.fatal! "php extension_dir cannot be empty" if php_extension_dir.empty?
    arr.concat shell_out!("find #{php_extension_dir} -type f").stdout.split
    arr << shell_out!("which php").stdout.chomp
    arr.concat %w(/dev/zero /dev/urandom /dev/null)
  end
end