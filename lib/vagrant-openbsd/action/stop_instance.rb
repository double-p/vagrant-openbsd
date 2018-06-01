module VagrantPlugins
  module OpenBSD
    module Action
      class StopInstance
        def initialize(app, env)
          @app    = app
          @machine = env[:machine]
        end

        def call(env)
          env[:ui].info("Stopping the machine...")
          @machine.provider.driver.stop(@machine.id)
          @app.call(env)
        end
      end
    end
  end
end
