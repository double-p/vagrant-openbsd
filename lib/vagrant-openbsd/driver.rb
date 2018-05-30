require "log4r"
require "io/console"
require "vagrant-openbsd/errors"
require "vagrant/util/subprocess"

module VagrantPlugins
  module OpenBSD
    class Driver

      attr_reader :vm_id
      attr_accessor :state

      def initialize(machine)
        @machine = machine
        @logger = Log4r::Logger.new("vagrant_openbsd::driver::initialize")
        if Process.uid == 0
          @vmctl = '/usr/sbin/vmctl'
        else
          @vmctl = '/usr/bin/doas /usr/sbin/vmctl'
        end
        puts "mooo!"
      end

      def check_vmm_support
        result = File.exist?("/dev/vmm")
        raise Errors::SystemVersionIsTooLow if result == 0
        result = execute("#{@sudo} /usr/sbin/rcctl -f check vmd")
        raise Errors::SystemCPUincapable if result == 1
      end

      def vmctl_exec(*command, &block)
        Vagrant::Util::Subprocess.execute(@vmctl, *command, &block)
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

      def to_s
        id = @machine.id.nil? ? "new" : @machine.id
        "OpenBSD (#{id})"
end
    end
  end
end
