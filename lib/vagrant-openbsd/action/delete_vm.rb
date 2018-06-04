module VagrantPlugins
  module OpenBSD
    module Action
      class DeleteVM
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info("Deleting the machine instance...")
          env[:machine].provider.driver.delete_vm(env[:machine])
          @app.call(env)
        end
      end
    end
  end
end
