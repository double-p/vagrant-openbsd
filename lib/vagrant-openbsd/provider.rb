require "vagrant"

require "vagrant-openbsd/action"

module VagrantPlugins
  module OpenBSD
    class Provider < Vagrant.plugin("2", :provider)
      def initialize(machine)
        @machine = machine
      end

      def initialize(machine)
        @logger = Log4r::Logger.new("vagrant::provider::openbsd")
        @machine = machine
      end

      def driver
        return @driver if @driver
        @driver = Driver.new(@machine)
      end

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
        # Attrmpt to get the action method from the Action class if it
        # exists, otherwise return nil to show that we don't support the
        # given action
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      # This should return the state of the machine within this provider.
      # The state must be an instance of {MachineState}. Please read the
      # documentation of that class for more information.
      #
      # @return [MachineState]
      def state
        state_id = nil
        if @machine.id
          vm_name       = driver.get_attr('vm_name')
          if vm_name.nil?
            state_id    = :uncreated
          else
            state_id    = driver.state(vm_name)
          end
        else
          state_id      = :uncreated
        end
        short = state_id.to_s.gsub("_", " ")
        long  = I18n.t("vagrant_bhyve.states.#{state_id}")
        # If we're not created, then specify the special ID flag
        state_id = Vagrant::MachineState::NOT_CREATED_ID if state_id == :uncreated
        # Return the MachineState object
        Vagrant::MachineState.new(state_id, short, long)
      end

      def to_s
        "OpenBSD Provider"
      end
    end
  end
end
