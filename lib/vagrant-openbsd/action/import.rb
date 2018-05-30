require "log4r"
require "securerandom"
#require "digest/md5"

module VagrantPlugins
  module OpenBSD
    module Action
      class Import

        def initialize(app, env)
          @logger = Log4r::Logger.new("vagrant_openbsd::action::import")
          @app = app
        end

        def call(env)
          @machine      = env[:machine]
          @driver       = @machine.provider.driver

          env[:ui].info I18n.t('vagrant_openbsd.action.vm.import_box')
          @machine.id   = SecureRandom.uuid
          vm_name   = @machine.id.gsub('-', '')[0..30]
          mac       = @driver.get_mac_address(vm_name)
          @driver.store_attr('vm_name', vm_name)
          @driver.import(@machine, env[:ui])
          @app.call(env)
        end

      end
    end
  end
end
