Vagrant.configure("2") do |config|
  config.vm.guest = :openbsd
  config.ssh.shell = "ksh -l"
  config.ssh.username = "root"
  config.ssh.password = "vagrant"
  config.ssh.forward_agent = true
  config.vm.box = "vagrobsd"
  config.vm.hostname = "openbsd-vagrant"
end
