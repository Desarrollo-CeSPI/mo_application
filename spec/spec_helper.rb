# Added by ChefSpec
require 'chefspec'

# Uncomment to use ChefSpec's Berkshelf extension
require 'chefspec/berkshelf'

RSpec.configure do |config|
  # Specify the path for Chef Solo to find cookbooks
  config.before(:suite) do 
    config.cookbook_path = [
      File.expand_path('../../..', __FILE__),
      File.expand_path('../cookbooks', __FILE__),
      config.cookbook_path
    ]

  end

  # Specify the path for Chef Solo to find roles
  # config.role_path = '/var/roles'

  # Specify the Chef log_level (default: :warn)
  # config.log_level = :debug

  # Specify the path to a local JSON file with Ohai data
  # config.path = 'ohai.json'

  # Specify the operating platform to mock Ohai data from
  # config.platform = 'ubuntu'

  # Specify the operating version to mock Ohai data from
  # config.version = '12.04'
end

#ChefSpec::Coverage.start!
at_exit { ChefSpec::Coverage.report! }

def chef_run_lwrp(resource, opts = {}, &block)
    options = {
      step_into: [resource.to_s]
    }.merge(opts)
    ChefSpec::Runner.new(options, &block)
end

