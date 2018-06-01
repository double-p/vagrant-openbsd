$inlprv=<<SCRIPT
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.guest = :openbsd
  config.ssh.shell = "ksh -l"
  config.ssh.sudo_command = "doas -n %c"
  config.ssh.username = "root"
  config.ssh.password = "vagrant"
  config.ssh.forward_agent = true
  config.vm.box = "vagrobsd"

  config.vm.define "vagrobsd" do |v|
    v.vm.hostname = "openbsd-vagrant"
    v.vm.provider :openbsd do |vb|
    end
    v.vm.provision "shell", inline: $inlprv
  end
end
