require "fileutils"

require "log4r"

module VagrantPlugins
  module OpenBSD
    module Action
      class Import
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::openbsd::import")
        end

        def call(env)
          # need this later when multiple disks
          vm_dir = env[:machine].box.directory
          hd_dir = env[:machine].box.directory
          memory = env[:machine].provider_config.memory
          cpus = env[:machine].provider_config.cpus
          vmname = env[:machine].provider_config.vmname
          enable_virtualization_extensions = env[:machine].provider_config.enable_virtualization_extensions

          env[:ui].output("Configured startup memory is #{memory}") if memory
          env[:ui].output("Configured cpus number is #{cpus}") if cpus
          env[:ui].output("Configured enable virtualization extensions is #{enable_virtualization_extensions}") if enable_virtualization_extensions
          env[:ui].output("Configured vmname is #{vmname}") if vmname

          if !vm_dir.directory? || !hd_dir.directory?
            raise "Box not valid: #{vm_dir} - #{hd_dir}"
          end

          config_path = nil
          config_type = nil
          vm_dir.each_child do |f|
            if f.extname.downcase == '.json'
              @logger.debug("Found JSON config...")
              config_path = f
              config_type = 'json'
              break
            end
          end

          image_path = nil
          image_ext = nil
          image_filename = nil
          hd_dir.each_child do |f|
            if %w{.img}.include?(f.extname.downcase)
              image_path = f
              image_ext = f.extname.downcase
              image_filename = File.basename(f, image_ext)
              break
            end
          end

          if !config_path || !image_path
            raise Errors::BoxInvalid
          end

          env[:ui].output("Importing an OpenBSD instance")
          env[:ui].detail("Cloning virtual hard drive...")
          source_path = image_path.to_s
          dest_path = env[:machine].data_dir.join("Virtual Hard Disks").join("#{image_filename}#{image_ext}").to_s

          options = options || {}
          options[:memory] = memory if memory
          options[:cpus] = cpus if cpus
          options[:vmname] = vmname if vmname
          env[:ui].detail("Creating and registering the VM...")
          server = env[:machine].provider.driver.import(options)

          env[:ui].detail("Successfully imported a VM with name: #{server['name']}")
          env[:machine].id = server["id"]
          @app.call(env)
        end
      end
    end
  end
end
