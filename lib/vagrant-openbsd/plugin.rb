begin
  require "vagrant"
rescue LoadError
  raise "The OpenBSD provider must be run within Vagrant."
end

require "vagrant-openbsd/host.rb"

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.1.0"
  raise "This OpenBSD provider is only compatible with Vagrant 1.1+"
end

module VagrantPlugins
  module OpenBSD
    class Plugin < Vagrant.plugin("2")
      name "OpenBSD provider"
      description "OpenBSD host and VMM provider support."

# Confighook not needed yet
      #config("vagrant-openbsd", :provider) do
        #require_relative "config"
        #Config
      #end

      provider "openbsd" do
        # init locales and logging
        OpenBSD.init_i18n
        OpenBSD.init_logging

        # Load the actual provider
        require_relative "provider"
        Provider
      end

# Host detection and capabilities
      host("openbsd") do
        require_relative "host"
        Host
      end

      host_capability("openbsd", "nfs_export") do
        require_relative "host/cap/nfs"
        Cap::NFS
      end

      # BSD-specific helpers
      host_capability("openbsd", "nfs_exports_template") do
        require_relative "host/cap/nfs"
        Cap::NFS
      end

      host_capability("openbsd", "nfs_restart_command") do
        require_relative "host/cap/nfs"
        Cap::NFS
      end
    end
  end
end
