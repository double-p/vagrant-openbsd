require "log4r"
require "io/console"
require "vagrant-openbsd/errors"
require "vagrant/util/subprocess"

module VagrantPlugins
  module OpenBSD
    class Driver

      # This executor is responsible for actually executing commands, including
      # bhyve, dnsmasq and other shell utils used to get VM's state
      # attr_accessor :executor

      def initialize(machine)
        @logger = Log4r::Logger.new("vagrant_openbsd::driver")
        @machine = machine
        @data_dir = @machine.data_dir
        #@executor = Executor::Exec.new

        if Process.uid == 0
          @sudo = ''
        else
          @sudo = '/usr/bin/doas'
        end
      end

      def check_vmm_support
        result = File.exist?("/dev/vmm")
        raise Errors::SystemVersionIsTooLow if result == 0
        result = execute("#{@sudo} /usr/sbin/rcctl -f check vmd")
        raise Errors::SystemCPUincapable if result == 1
      end

      def import(machine, ui)
        box_dir         = machine.box.directory
        instance_dir    = @data_dir
        store_attr('id', machine.id)
        exec("ls -l /tmp/#{machine.id}")
      end

      def boot(machine, ui)
        directory   = @data_dir
        config      = machine.provider_config
        vmconfig    = machine.config
        #image       = config.image
        uuid = get_attr('id')

        #vmctl_cmd = "#{@sudo} /usr/sbin/vmctl start -c -L "
        vmctl_cmd = "#{@sudo} /usr/sbin/vmctl status; echo #{uuid}"
        #vmctl_cmd += "#{vmconfig.vm_name}" #XXX dump a vm-config-hash
        #vmctl_cmd += " -m #{config.memory}"
        #vmctl_cmd += " -i #{config.nif}"
        #vmctl_cmd += " 'moo' -d #{machine.box.directory}/disk.img -L -c"
        exec(vmctl_cmd)
      end

      def ip_ready?
        mac         = get_attr('mac')
        return true
      end

      def ssh_ready?(ssh_info)
        if ssh_info
          return exec("nc -z #{ssh_info[:host]} #{ssh_info[:port]}")
        end
        return false
      end

      def execute(*command, &block)
        r = exec(*command, &block)

        # If the command was a failure, then raise an exception that is
        # nicely handled by Vagrant.
        if r.exit_code != 0
          if @interrupted
            @logger.info('Exit code != 0, but interrupted. Ignoring.')
          else
            # If there was an error running command, show the error and the
            # output.
            raise VagrantPlugins::OpenBSD::Errors::ExecutionError,
              :command => command.inspect,
              :stderr  => r.stderr
          end
        end
        r.stdout
      end
    end
  end
end
