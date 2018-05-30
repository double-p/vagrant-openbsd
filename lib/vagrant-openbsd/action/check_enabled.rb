require "fileutils"

require "log4r"

module VagrantPlugins
  module OpenBSD
    module Action
      class CheckEnabled
        def initialize(app, env)
          @app    = app
        end

        def call(env)
          env[:ui].output("Verifying VMM present and CPU capable...")
          env[:machine].provider.driver.check_vmm_support

          @app.call(env)
        end
      end
    end
  end
end
