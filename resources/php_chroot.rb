include CespiApplication::ChrootResourceBase
include CespiApplication::PhpChrootResourceBase

def initialize(name, run_context=nil)
  super
  @copy_files = lazy { php_fpm_required_files }
  @provider = lookup_provider_constant :cespi_application_chroot
end

