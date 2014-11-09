require_relative '../spec_helper'

describe 'fake_deploy::create'do
  # Use an explicit subject
  let(:chef_run) { chef_run_lwrp(:mo_application_deploy).converge(described_recipe)  }

  context "default_action" do
    it 'uses defaults' do
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
  end

  context "with_before_deploy" do
    it 'uses defaults' do
      expect(chef_run).to create_directory('/tmp/some_other_path').with(
        owner: 'with_before_deploy',
        group: 'with_before_deploy'
      )

      expect(chef_run).to create_directory('/tmp/some_other_path/shared').with(
        owner: 'with_before_deploy',
        group: 'with_before_deploy'
      )

      expect(chef_run).to deploy_deploy('with_before_deploy').with(
        provider: Chef::Provider::Deploy::Revision,
        deploy_to: "/tmp/some_other_path",
        repo: 'some repo',
        revision: 'HEAD',
        purge_before_symlink: [],
        create_dirs_before_symlink: [],
        symlinks: {},
        user: 'with_before_deploy',
        group: 'with_before_deploy',
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
  end

  context "with_shared_files_and_dirs" do
    it 'uses defaults' do
      expect(chef_run).to create_directory('/tmp/shared_test').with(
        owner: 'with_shared_files_and_dirs',
        group: 'with_shared_files_and_dirs'
      )

      expect(chef_run).to create_directory('/tmp/shared_test/shared').with(
        owner: 'with_shared_files_and_dirs',
        group: 'with_shared_files_and_dirs'
      )

      expect(chef_run).to deploy_deploy('with_shared_files_and_dirs').with(
        provider: Chef::Provider::Deploy::Revision,
        deploy_to: "/tmp/shared_test",
        repo: 'some repo',
        revision: 'HEAD',
        purge_before_symlink: ['log'],
        create_dirs_before_symlink: [],
        symlinks: {"other_dir/log"=>"log"},
        user: 'with_shared_files_and_dirs',
        group: 'with_shared_files_and_dirs',
        migrate: false,
        migration_command: nil,
        action: [:deploy]
      )
    end

    it 'creates shared_dirs as specified' do
      expect(chef_run).to create_directory('/tmp/shared_test/shared/some_dir/config').with(
        owner: 'with_shared_files_and_dirs',
        group: 'with_shared_files_and_dirs')
      expect(chef_run).to create_directory('/tmp/shared_test/shared/other_dir/log').with(
        owner: 'with_shared_files_and_dirs',
        group: 'with_shared_files_and_dirs')
    end
  end
end

describe 'fake_deploy::remove'do
  # Use an explicit subject
  let(:chef_run) { chef_run_lwrp(:mo_application_deploy).converge(described_recipe)  }

  it 'removes path completely' do
    expect(chef_run).to delete_directory('/tmp/some_path_to_remove').with(recursive: true)
  end
end
