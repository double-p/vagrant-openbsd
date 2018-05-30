require "vagrant"

module VagrantPlugins
  module OpenBSD
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :memory #  Memory size in mb @return [Integer]
      attr_accessor :cpus # Number of cpu's @return [Integer]
      attr_accessor :vmname # Name that will be shoen in Hyperv Manager @return [String]
      attr_accessor :interfaces # number network interface for the virtual machine. @return [Integer]

      def initialize
        @memory = UNSET_VALUE
        @cpus = UNSET_VALUE
        @vmname = UNSET_VALUE
        @interfaces = UNSET_VALUE
      end

      def finalize!
        @memory = nil if @memory == UNSET_VALUE
        @cpus = nil if @cpus == UNSET_VALUE
        @vmname = nil if @vmname == UNSET_VALUE
        if @interfaces == UNSET_VALUE
          @interfaces = 1
        end
      end

      def validate(machine)
        errors = _detected_errors

        {"OpenBSD" => errors}
      end
    end
  end
end

