# Added by ChefSpec
require 'chefspec'

# Uncomment to use ChefSpec's Berkshelf extension
#require 'chefspec/berkshelf'

RSpec.configure do |config|
  # Specify the path for Chef Solo to find cookbooks
  config.cookbook_path = [
    File.expand_path('../../..', __FILE__),
    File.expand_path('../cookbooks', __FILE__),
  ]

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

def chef_run_lwrp(resource, opts = {})
    options = {
      step_into: [resource.to_s]
    }.merge(opts)
    ChefSpec::Runner.new(options)
end

#Add shell out expectation
def expects_shell_out(command,at_least: :once)
  shellout =  double
  [:live_stream=, :run_command, :error!].each do |method|
    allow(shellout).to receive(method)
  end
  allow(shellout).to receive(:error?).and_return(false)
  allow(shellout).to receive(:stdout).and_return("")
  expect(Mixlib::ShellOut).to receive(:new).with(command).at_least(at_least).and_return(shellout)
end
