require "vagrant"

module VagrantPlugins
  module HostOpenBSD
    class Host < Vagrant.plugin("2", :host)
      def detect?(env)
        result = Vagrant::Util::Subprocess.execute("/bin/sh", "-c",
          "uname -s | grep -q OpenBSD")
        return result
      end
      false
    end
  end
end
