require "pathname"
require "vagrant/action/builder"

# all heavily based on https://github.com/jesa7955/vagrant-bhyve

module VagrantPlugins
  module OpenBSD
    module Action
      include Vagrant::Action::Builtin
      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :Boot, action_root.join('boot')
      #autoload :Load, action_root.join('load')
      autoload :WaitUntilUP, action_root.join('wait_until_up')
      #autoload :ForwardPorts, action_root.join('forward_ports')

      def self.action_up
        Vagrant::Action::Builder.new.tap do |up|
          up.use action_boot
        end
      end

      def self.action_boot
        Vagrant::Action::Builder.new.tap do |boot|
          #boot.use Load
          boot.use Boot
          boot.use Call, WaitUntilUP do |env, b1|
            if env[:uncleaned]
              b1.use action_reload
            else
              #b1.use ForwardPorts
            end
          end
        end
      end

    end # mod Action
  end # mod OpenBSD
end
