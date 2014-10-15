require_relative '../spec_helper'

describe 'fake_user::create'do
  # Use an explicit subject
  let(:chef_run) { chef_run_lwrp(:cespi_application_user).converge(described_recipe)  }

  it 'set defaults' do
    expect(chef_run).to create_group('user_default')
    expect(chef_run).to create_user('user_default').with(
      supports: {manage_home: true},
      home: '/home/user_default',
      gid:  'user_default',
      shell: '/bin/bash')
  end

  it 'creates a diferent group when specified' do
    expect(chef_run).to create_group('some_group')
    expect(chef_run).to create_user('user_group').with(gid: 'some_group')
  end

  it 'uses diferent home' do
    expect(chef_run).to create_group('temporary_home')
    expect(chef_run).to create_user('temporary_home').with(
      supports: {manage_home: true},
      home: '/tmp/temporary_home'
    )
  end

  it 'uses diferent shell' do
    expect(chef_run).to create_group('dont_like_bash')
    expect(chef_run).to create_user('dont_like_bash').with(shell: '/bin/sh')
  end

end

describe 'fake_user::remove'do
  # Use an explicit subject
  let(:chef_run) { chef_run_lwrp(:cespi_application_user).converge(described_recipe)  }

  it 'removes group and user defaults' do
    expect(chef_run).to remove_user('testuser').with(supports: { manage_home: true})
    expect(chef_run).to remove_group('testuser')
  end
end
