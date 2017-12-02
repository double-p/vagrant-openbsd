require "vagrant"

module VagrantPlugins
  module HostOpenBSD
    class Plugin < Vagrant.plugin("2")
      name "OpenBSD host"
      description "OpenBSD host support."

      host("openbsd", "bsd") do
        require_relative "host"
        Host
      end

      host_capability("openbsd", "nfs_export") do
        require_relative "cap/nfs"
        Cap::NFS
      end

      # BSD-specific helpers
      host_capability("openbsd", "nfs_exports_template") do
        require_relative "cap/nfs"
        Cap::NFS
      end

      host_capability("openbsd", "nfs_restart_command") do
        require_relative "cap/nfs"
        Cap::NFS
      end
    end
  end
end
