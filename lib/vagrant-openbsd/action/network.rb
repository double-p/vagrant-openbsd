require "log4r"
require "ipaddr"
require "set"

require "vagrant/util/network_ip"
#require "vagrant/util/scoped_hash_override"

module VagrantPlugins
  module ProviderVirtualBox
    module Action
      # This middleware class sets up all networking for the OpenBSD VMM
      # instance. This includes host only networks, bridged networking,
      # forwarded ports, etc.
      #
      # This handles all the `config.vm.network` configurations.
      class Network
        include Vagrant::Util::NetworkIP
        include Vagrant::Util::ScopedHashOverride

        def initialize(app, env)
          @logger = Log4r::Logger.new("vagrant::plugins::openbsd::network")
          @app    = app
        end

        def call(env)
          @env = env
          @app.call(env)
        end
      end
    end
  end
end
# TODO list
#        def hostonly_config(options)
#        def hostonly_adapter(config)
#        def hostonly_network_config(config)
#        def intnet_config(options)
#        def intnet_adapter(config)
#        def intnet_network_config(config)
#        def bridged_config(options)
#        def bridged_adapter(config)
#        def bridged_network_config(config)
#        def assign_interface_numbers(networks, adapters)
#        def hostonly_create_network(config)
#        def hostonly_find_matching_network(config)
#        def nat_config(options)
#        def nat_adapter(config)
#        def nat_network_config(config)
