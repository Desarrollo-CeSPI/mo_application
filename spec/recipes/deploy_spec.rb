require_relative '../spec_helper'

describe 'fake_deploy::create'do
  # Use an explicit subject
  let(:chef_run) { chef_run_lwrp(:cespi_application_deploy).converge(described_recipe)  }

  it 'deploys an application with defaults' do
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
      deploy_to: "/tmp/some_path",
      repo: 'some repo',
      revision: 'HEAD',
      purge_before_symlink: [],
      create_dirs_before_symlink: [],
      symlinks: {},
      user: 'default_action',
      group: 'default_action',
      migrate: false,
      migration_command: nil,
      action: [:deploy]
    )

  end

  it 'calls before_deploy' do
    expect(chef_run).to create_template('/tmp/some.template')
  end

  it 'uses application_template helper' do
    expect(chef_run).to create_template('/tmp/some_other_path/shared/config/databases.yml')
  end

  it 'creates shared_dires as specified' do
    expect(chef_run).to create_directory('/tmp/shared_test/shared/some_dir/config').with(
      owner: 'with_shared_files_and_dirs',
      group: 'with_shared_files_and_dirs')
    expect(chef_run).to create_directory('/tmp/shared_test/shared/other_dir/log').with(
      owner: 'with_shared_files_and_dirs',
      group: 'with_shared_files_and_dirs')
  end
end

describe 'fake_deploy::remove'do
  # Use an explicit subject
  let(:chef_run) { chef_run_lwrp(:cespi_application_deploy).converge(described_recipe)  }

  it 'removes path completely' do
    expect(chef_run).to delete_directory('/tmp/some_path_to_remove').with(recursive: true)
  end
end
