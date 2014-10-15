if defined?(ChefSpec)
  def create_cespi_application_user(message)
    ChefSpec::Matchers::ResourceMatcher.new(:cespi_application_user, :create, message)
  end

  def remove_cespi_application_user(message)
    ChefSpec::Matchers::ResourceMatcher.new(:cespi_application_user, :remove, message)
  end

  def create_cespi_application_chroot(message)
    ChefSpec::Matchers::ResourceMatcher.new(:cespi_application_chroot, :create, message)
  end

  def remove_cespi_application_chroot(message)
    ChefSpec::Matchers::ResourceMatcher.new(:cespi_application_chroot, :remove, message)
  end

  def create_cespi_application_deploy(message)
    ChefSpec::Matchers::ResourceMatcher.new(:cespi_application_deploy, :create, message)
  end

  def remove_cespi_application_deploy(message)
    ChefSpec::Matchers::ResourceMatcher.new(:cespi_application_deploy, :remove, message)
  end

  def create_cespi_application_database(message)
    ChefSpec::Matchers::ResourceMatcher.new(:cespi_application_database, :create, message)
  end

end
