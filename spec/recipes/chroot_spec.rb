require_relative '../spec_helper'

describe 'fake_chroot::create'do
  # Use an explicit subject
  let(:chef_run) { chef_run_lwrp(:cespi_application_chroot).converge(described_recipe)  }
  let(:base) { '/tmp/default_chroot' }
  let(:shellout) { double }


  before do
    %w( /etc/hosts /etc/resolv.conf /etc/services).each do |etc|
      stub_command("test -e /tmp/default_chroot#{etc}").and_return(false)
    end
    [:live_stream=, :run_command, :error!].each do |method|
      allow(shellout).to receive(method)
    end
    allow(shellout).to receive(:error?).and_return(false)
    allow(shellout).to receive(:stdout).and_return("")
  end

  it 'creates chroot with defaults' do
    %w(/etc /dev /log /run /tmp /var).each do |dir|
      expect(chef_run).to create_directory(::File.join base, dir).with(recursive: true)
    end
  end

  it 'copies default /etc files' do
     %w( /etc/hosts /etc/resolv.conf /etc/services).each do |etc|
        expect(Mixlib::ShellOut).to receive(:new).with("ldd #{etc}").at_least(:once).and_return(shellout)
     end
     %w( /etc/hosts /etc/resolv.conf /etc/services).each do |etc|
        expect(Mixlib::ShellOut).to receive(:new).with("cp -aL #{etc} #{::File.join base, etc}").at_least(:once).and_return(shellout)
     end
     %w( /etc/hosts /etc/resolv.conf /etc/services).each do |etc|
        expect(chef_run).to run_ruby_block("copy file #{etc}")
        chef_run.find_resources(:ruby_block).find { |r| r.name == "copy file #{etc}" }.old_run_action(:create)
     end
  end
end


