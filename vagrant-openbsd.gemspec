
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vagrant-openbsd/version"

Gem::Specification.new do |spec|
  spec.name          = "vagrant-openbsd"
  spec.version       = VagrantPlugins::HostOpenBSD::VERSION
  spec.authors       = ["Philipp Buehler"]
  spec.email         = ["pbuehler@sysfive.com"]

  spec.summary       = %q{OpenBSD host caps for vagrant.}

  spec.description   = %q{Adds OpenBSD host detection + capabilites for Vagrant.}
  spec.homepage      = "https://github.com/double-p/vagrant-openbsd"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "vagrant-spec", "~> 1.4.0"
end
