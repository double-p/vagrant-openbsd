require "vagrant"

require "vagrant-openbsd/action"

module VagrantPlugins
  module OpenBSD
    class Provider < Vagrant.plugin("2", :provider)
      def initialize(machine)
        @logger = Log4r::Logger.new("vagrant::provider::openbsd")
        @machine = machine
      end

      def driver
        return @driver if @driver
        @driver = Driver.new(@machine)
      end

   # driver?
      def ssh_info
        # We just return nil if were not able to identify the VM's IP and
        # let Vagrant core deal with it like docker provider does
        return nil if state.id != :running
        tap_device      = driver.get_attr('tap')
        ip              = driver.get_ip_address(tap_device) unless tap_device.length == 0
        return nil if !ip
        ssh_info = {
          host: ip,
          port: 22,
        }
      end

      def action(name)
        # Attempt to get the action method from the Action class if it
        # exists, otherwise return nil to show that we don't support the
        # given action
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

    end
  end
end
