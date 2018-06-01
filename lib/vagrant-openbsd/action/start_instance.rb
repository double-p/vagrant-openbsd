module VagrantPlugins
  module OpenBSD
    module Action
      class StartInstance
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
        end

        def call(env)
          env[:ui].output('Starting the machine...')
          @machine.provider.driver.start(@machine)
          @app.call(env)
        end
      end
    end
  end
end
