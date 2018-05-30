module VagrantPlugins
  module OpenBSD
    module Action
      class StartInstance
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].output('Starting the machine...')
          env[:machine].provider.driver.start
          @app.call(env)
        end
      end
    end
  end
end
