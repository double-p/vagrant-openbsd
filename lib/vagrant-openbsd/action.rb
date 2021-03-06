require "pathname"
require "vagrant/action/builder"
require "vagrant-openbsd/driver"

# all heavily based on hyperv action.rb

# all vagrant-actions (up, halt,..) are redirected to here as
# action_xyz.
# This file delegates some to action/whatever.rb and actions might
# call functions in driver.rb
module VagrantPlugins
  module OpenBSD
    module Action
      include Vagrant::Action::Builtin

      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_openbsd.message_not_created")
              next
            end

            b2.use action_halt
            b2.use action_start
          end
        end
      end

      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, IsState, :not_created do |env1, b1|
            if env1[:result]
              b1.use Message, I18n.t("vagrant_openbsd.message_not_created")
              next
            end

            b1.use Call, DestroyConfirm do |env1, b2|
              if !env1[:result]
                b2.use Message, I18n.t(
                  'vagrant.commands.destroy.will_not_destroy',
                  name: env1[:machine].name)
                next
              end
              b2.use Call, IsState, :running do |env2, b3|
                if env2[:result]
                  b3.use action_halt
                end
              end
              b2.use DeleteVM
            end
          end
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_openbsd.message_not_created")
              next
            end

            b2.use Call, GracefulHalt, :stopped, :running do |env2, b3|
              if !env2[:result]
                b3.use StopInstance
              end
            end
          end
        end
      end

      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_openbsd.message_not_created")
              next
            end

            b2.use Call, IsState, :running do |env1, b3|
              if !env1[:result]
                b3.use Message, I18n.t("vagrant_openbsd.message_not_running")
                next
              end

              b3.use Provision
            end
          end
        end
      end

      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBox
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b1|
            if env[:result]
              b1.use Message, I18n.t("vagrant_openbsd.message_not_created")
              next
            end

            b1.use ResumeVM
            b1.use WaitForIPAddress
            sleep 2 #XXX noisy debug
            b1.use WaitForCommunicator, [:running] # from builtin
          end
        end
      end

      def self.action_start
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, IsState, :running do |env1, b1|
            if env1[:result]
              b1.use action_provision
              next
            end
          b.use StartInstance
          sleep 10 # noisy debug
          b.use WaitForIPAddress
          sleep 15 # noisy debug
          b.use WaitForCommunicator, [:running]
          #b.use Network

            b1.use Call, IsState, :paused do |env2, b2|
              if env2[:result]
                b2.use action_resume
                next
              end

              b2.use Provision
              #b2.use NetSetMac
              b2.use StartInstance
              b2.use WaitForIPAddress
              sleep 10 # noisy debug
              b2.use WaitForCommunicator, [:running]
              #b2.use Network
              #b2.use SyncedFolderCleanup
              #b2.use SyncedFolders
              #dafuq#b2.use SetHostname
            end
          end
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckEnabled
          b.use HandleBox
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env1, b1|
            if env1[:result]
              b1.use Import
            end

            b1.use action_start
          end
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              raise Vagrant::Errors::VMNotCreatedError
            end

            b2.use Call, IsState, :running do |env1, b3|
              if !env1[:result]
                raise Vagrant::Errors::VMNotRunningError
              end

              b3.use SSHExec
            end
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              raise Vagrant::Errors::VMNotCreatedError
            end

            b2.use Call, IsState, :running do |env1, b3|
              if !env1[:result]
                raise Vagrant::Errors::VMNotRunningError
              end

              b3.use SSHRun
            end
          end
        end
      end

      def self.action_suspend
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_openbsd.message_not_created")
              next
            end

            b2.use SuspendVM
          end
        end
      end

      def self.action_snapshot_delete
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_openbsd.message_not_created")
              next
            end

            b2.use SnapshotDelete

          end
        end
      end

      def self.action_snapshot_restore
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_openbsd.message_not_created")
              next
            end

            b2.use action_halt
            b2.use SnapshotRestore

            b2.use Call, IsEnvSet, :snapshot_delete do |env2, b3|
              if env2[:result]
                b3.use action_snapshot_delete
              end
            end

            b2.use action_start

          end
        end
      end

      def self.action_snapshot_save
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_openbsd.message_not_created")
              next
            end
            b2.use SnapshotSave
          end
        end
      end

      # The autoload farm, export/package tbd in the winter..
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      #autoload :PackageSetupFolders, action_root.join("package_setup_folders")
      #autoload :PackageSetupFiles, action_root.join("package_setup_files")
      #autoload :PackageVagrantfile, action_root.join("package_vagrantfile")
      #autoload :PackageMetadataJson, action_root.join("package_metadata_json")
      #autoload :Export, action_root.join("export")
      #autoload :Package, action_root.join("package")

      autoload :CheckEnabled, action_root.join("check_enabled")
      autoload :DeleteVM, action_root.join("delete_vm")
      autoload :Import, action_root.join("import")
      autoload :IsWindows, action_root.join("is_windows")
      autoload :ResumeVM, action_root.join("resume_vm")
      autoload :StartInstance, action_root.join('start_instance')
      autoload :StopInstance, action_root.join('stop_instance')
      autoload :SuspendVM, action_root.join("suspend_vm")
      autoload :WaitForIPAddress, action_root.join("wait_for_ip_address")
      autoload :Network, action_root.join("network")
      #autoload :NetSetVLan, action_root.join("net_set_vlan")
      autoload :NetSetMac, action_root.join("net_set_mac")
      autoload :MessageWillNotDestroy, action_root.join("message_will_not_destroy")
      autoload :SnapshotDelete, action_root.join("snapshot_delete")
      autoload :SnapshotRestore, action_root.join("snapshot_restore")
      autoload :SnapshotSave, action_root.join("snapshot_save")
    end
  end
end
