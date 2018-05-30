require "vagrant"

module VagrantPlugins
  module OpenBSD
    module Errors
      class OpenBSDError < Vagrant::Errors::VagrantError
	error_namespace('vagrant_openbsd.errors')
      end

      class SystemVersionIsTooLow < OpenBSDError
	error_key(:system_version_too_low)
      end

      class SystemCPUincapable < OpenBSDError
	error_key(:system_cpu_incapable)
      end

    end
  end
end
