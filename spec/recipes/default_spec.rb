require_relative '../spec_helper'

describe 'cespi_application::test_deploy'do
  # Use an explicit subject
  let(:chef_run) { ChefSpec::Runner.new(step_into:['cespi_application_deploy']).converge(described_recipe) }

  it 'deploys an application with the default action' do

    expect(chef_run).to create_group('default_action')

    expect(chef_run).to create_user('default_action').with(
      gid: 'default_action',
      shell: '/bin/bash',
      home: '/home/default_action',
      supports: {manage_home: true}
    )

    expect(chef_run).to create_directory('/tmp/some_path').with(
      owner: 'default_action',
      group: 'default_action'
    )

    expect(chef_run).to create_directory('/tmp/some_path/shared').with(
      owner: 'default_action',
      group: 'default_action'
    )

    expect(chef_run).to deploy_deploy('default_action').with(
      provider: Chef::Provider::Deploy::Revision,
      repo: 'some repo',
      revision: 'HEAD'
    )
  end
end
