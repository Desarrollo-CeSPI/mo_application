require_relative '../spec_helper'


describe 'fake_chroot::create'do
  # Use an explicit subject
  let(:chef_run) do 
    shell_out_ldd_error = double("Shell Out ldd command", :error? => true)
    chef_run_lwrp(:cespi_application_chroot).converge(described_recipe) do
      allow_any_instance_of(Chef::Provider::CespiApplicationChroot).to receive(:shell_out).with(/^ldd .*/).and_return shell_out_ldd_error
    end
  end
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
      expect(chef_run).to run_ruby_block("copy file #{etc}")
      r = chef_run.find_resources(:ruby_block).find { |rs| rs.name == "copy file #{etc}" }
      expect(r).to receive(:shell_out!).with("cp -aL #{etc} #{::File.join base, etc}")
      r.old_run_action(:create)
    end
  end

end

describe 'fake_chroot::create_with_files'do
  let(:copy_files) { %w(/dev/null /bin/bash) }
  let(:ldd_bin_bash) { %q(/lib/some_lib.so => unusable_data => /lib/other_lib.so) }
  let(:chef_run) do 
    shell_out_ldd_error = double("Shell Out ldd command", :error? => true)
    shell_out_ldd_bin_bash = double("Shell Out ldd /bin/bash command", :error? => false, :stdout => ldd_bin_bash)
    chef_run_lwrp(:cespi_application_chroot).converge(described_recipe) do |node|
      allow_any_instance_of(Chef::Provider::CespiApplicationChroot).to receive(:shell_out).with(/^ldd .*/).and_return shell_out_ldd_error
      allow_any_instance_of(Chef::Provider::CespiApplicationChroot).to receive(:shell_out).with(/^ldd \/bin\/bash/).and_return shell_out_ldd_bin_bash
    end
  end

  let(:base) { '/tmp/chroot_with_copy_files' }
  let(:etc_files) { %w( /etc/hosts /etc/resolv.conf /etc/services) }
  let(:all_files) { copy_files + etc_files + %w(/lib/some_lib.so /lib/other_lib.so) }

  before do
    all_files.each do |file|
      stub_command("test -e #{base+file}").and_return(false)
    end
  end

  it 'creates chroot with defaults' do
    %w(/etc /dev /log /run /tmp /var).each do |dir|
      expect(chef_run).to create_directory(::File.join base, dir).with(recursive: true)
    end
    expect(chef_run).to create_directory(::File.join base, 'bin').with(recursive: true)
    expect(chef_run).to create_directory(::File.join base, 'lib').with(recursive: true)
  end

  it 'copies default /etc files' do
    all_files.each do |etc|
      expect(chef_run).to run_ruby_block("copy file #{etc}")
      r = chef_run.find_resources(:ruby_block).find { |rs| rs.name == "copy file #{etc}" }
      expect(r).to receive(:shell_out!).with("cp -aL #{etc} #{::File.join base, etc}")
      r.old_run_action(:create)
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
