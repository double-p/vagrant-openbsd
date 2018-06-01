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

      def state
        # Run a custom action we define called "read_state" which does
        # what it says. It puts the state in the `:machine_state_id`
        # key in the environment. #from cloudstack
        env = @machine.action("read_state")
        state_id = env[:machine_state_id]

        # Get the short and long description
        short    = I18n.t("vagrant_openbsd.states.short_#{state_id}")
        long     = I18n.t("vagrant_openbsd.states.long_#{state_id}")

        # Return the MachineState object
        Vagrant::MachineState.new(state_id, short, long)
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

      def state
        state_id = nil
        state_id = :not_created unless @machine.id
        state_id = :not_created if !state_id && !@machine.id
        # Query the driver for the current state of the machine
        state_id = driver.get_state(@machine.id) if @machine.id && !state_id
        state_id = :unknown unless state_id

        long  = I18n.t("vagrant_openbsd.states.long_#{state_id}")

        # If we're not created, then specify the special ID flag
        if state_id == :not_created
          state_id = Vagrant::MachineState::NOT_CREATED_ID
        end

        # Return the MachineState object
        Vagrant::MachineState.new(state_id, state_id, long)
      end

      def to_s
        id = @machine.id.nil? ? "new" : @machine.id
        "OpenBSD (#{id})"
      end

    end
  end
end
