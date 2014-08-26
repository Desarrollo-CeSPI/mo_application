require_relative '../spec_helper'


describe 'fake_chroot::create'do
  # Use an explicit subject
  let(:chef_run) { chef_run_lwrp(:cespi_application_chroot).converge(described_recipe)  }
  let(:base) { '/tmp/default_chroot' }
  let(:etc_files) { %w( /etc/hosts /etc/resolv.conf /etc/services) }

  before do
    etc_files.each do |file|
      stub_command("test -e #{base+file}").and_return(false)
    end
  end

  it 'creates chroot with defaults' do
    %w(/etc /dev /log /run /tmp /var).each do |dir|
      expect(chef_run).to create_directory(::File.join base, dir).with(recursive: true)
    end
  end

  it 'copies default /etc files' do
    etc_files.each do |etc|
      expects_shell_out("ldd #{etc}")
    end

    etc_files.each do |etc|
      expects_shell_out("cp -aL #{etc} #{::File.join base, etc}")
    end

    etc_files.each do |etc|
      expect(chef_run).to run_ruby_block("copy file #{etc}")
      chef_run.find_resources(:ruby_block).find { |r| r.name == "copy file #{etc}" }.old_run_action(:create)
    end
  end

end

describe 'fake_chroot::create_with_files'do
  let(:chef_run) { chef_run_lwrp(:cespi_application_chroot).converge(described_recipe)  }
  let(:base) { '/tmp/chroot_with_copy_files' }
  let(:copy_files) { %w(/dev/null /bin/bash) }
  let(:etc_files) { %w( /etc/hosts /etc/resolv.conf /etc/services) }
  let(:all_files) { copy_files + etc_files }

  before do
    cmd = Mixlib::ShellOut.new("ldd /bin/bash")
    (cmd.run_command.stdout.split.grep(/^\//) +
      all_files).each do |file|
      stub_command("test -e #{base+file}").and_return(false)
    end
  end

  it 'creates chroot with defaults' do
    %w(/etc /dev /log /run /tmp /var).each do |dir|
      expect(chef_run).to create_directory(::File.join base, dir).with(recursive: true)
    end
    expect(chef_run).to create_directory(::File.join base, 'bin').with(recursive: true)
  end

  it 'copies default /etc files' do
    all_files.each do |etc|
      expects_shell_out("ldd #{etc}")
    end

    all_files.each do |etc|
      expects_shell_out("cp -aL #{etc} #{::File.join base, etc}")
    end

    all_files.each do |etc|
      expect(chef_run).to run_ruby_block("copy file #{etc}")
      chef_run.find_resources(:ruby_block).find { |r| r.name == "copy file #{etc}" }.old_run_action(:create)
    end
  end

end

describe 'fake_chroot::remove'do
  let(:base) { '/tmp/chroot_to_remove' }
  let(:chef_run) { chef_run_lwrp(:cespi_application_chroot).converge(described_recipe)  }
  it 'removes directory' do
    expect(chef_run).to delete_directory(base).with(recursive: true)
  end
end
