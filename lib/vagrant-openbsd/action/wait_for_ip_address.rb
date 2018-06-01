require "ipaddr"
require "timeout"

module VagrantPlugins
  module OpenBSD
    module Action
      class WaitForIPAddress
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::openbsd::wait_for_ip_addr")
        end

        def call(env)
          timeout = env[:machine].provider_config.ip_address_timeout

          env[:ui].output("Waiting for the machine to report its IP address...")
          env[:ui].detail("Timeout: #{timeout} seconds")

          guest_ip = nil
          Timeout.timeout(timeout) do
            while true
              # If a ctrl-c came through, break out
              return if env[:interrupted]

              # Try to get the IP
              begin
                tap_ip = env[:machine].provider.driver.read_tap_ip(env[:machine].id).chomp

                if tap_ip
                  begin
                    IPAddr.new(tap_ip)
                    guest_ip = tap_ip.succ
                    break
                  rescue IPAddr::InvalidAddressError
                    # Ignore, continue looking.
                    @logger.warn("Invalid IP address returned: #{guest_ip}")
                  end
                sleep 3
                end
              rescue Errors::OpenBSDError
                # Ignore, continue looking.
                @logger.warn("Failed to read guest IP.")
              end
              sleep 3
            end
          end

          # If we were interrupted then return now
          return if env[:interrupted]

          env[:ui].detail("IP: #{guest_ip}")

          @app.call(env)
        rescue Timeout::Error
          raise Errors::IPAddrTimeout
        end
      end
    end
  end
end
