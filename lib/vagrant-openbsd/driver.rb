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
      end

      def check_vmm_support
        result = File.exist?("/dev/vmm")
        raise Errors::SystemVersionIsTooLow if result == 0
        result = exec("#{@sudo} /usr/sbin/rcctl -f check vmd")
        raise Errors::SystemCPUincapable if result == 1
      end

      def vmctl_exec(*command, &block)
        Vagrant::Util::Subprocess.execute(@vmctl, *command, &block)
      end

    end
  end
end
