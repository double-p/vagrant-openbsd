require "log4r"

module VagrantPlugins
  module OpenBSD
    module Action
      class Boot

        def initialize(app, env)
          @logger = Log4r::Logger.new("vagrant_openbsd::action::boot")
          @app = app
        end

        def call(env)
          @machine      = env[:machine]
          @driver       = @machine.provider.driver

          env[:ui].detail I18n.t('vagrant_openbsd.action.vm.boot.booting')
          @driver.boot(@machine, env[:ui])

          @app.call(env)
        end

      end
    end
  end
end
