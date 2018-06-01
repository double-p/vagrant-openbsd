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
          @sudo = ''
        else
          @sudo = 'doas'
        end
      end

      def execute(*command, &block)
        # Get the options hash if it exists
        opts = {}
        opts = command.pop if command.last.is_a?(Hash)

        tries = 0
        tries = 3 if opts[:retryable]

        # Variable to store our execution result
        r = nil
        r = raw(*command, &block)
        r.stdout
      end
      # Executes a command and returns the raw result object.
      def raw(*command, &block)
        int_callback = lambda do
          @interrupted = true

          # We have to execute this in a thread due to trap contexts
          # and locks.
          Thread.new { @logger.info("Interrupted.") }.join
        end

        # Append in the options for subprocess
        command << { notify: [:stdout, :stderr] }

        Vagrant::Util::Busy.busy(int_callback) do
          Vagrant::Util::Subprocess.execute(*command, &block)
        end
      rescue Vagrant::Util::Subprocess::LaunchError => e
        raise Vagrant::Errors::OpenBSDError,
          message: e.to_s
      end

      def import(source_path, dest_path, options)
        FileUtils.copy(source_path, dest_path)
      end

      def check_vmm_support
        result = File.exist?("/dev/vmm")
        raise Errors::SystemVersionIsTooLow if result == 0
        raise Errors::SystemCPUincapable if !
          Vagrant::Util::Subprocess.execute("/bin/sh", "-c", "#{@sudo} rcctl -f check vmd")
        raise Errors::SystemCPUincapable if result == 1
        return true
      end

      def vmctl_exec(command)
        block = nil
        ret = execute("/bin/sh", "-c", "#{@sudo} vmctl #{command} | sed -n 2p", &block)
        ret
      end

      def get_state(id)
        result = vmctl_exec("status #{id}")
        state = :running if result.to_s.match(/ttyp/)
        state = :stopping if result.to_s.match(/stop$/)
        state = :stopped if result.to_s.match(/-       -/)
        state
      end

    end
  end
end
