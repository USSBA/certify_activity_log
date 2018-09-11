# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'certify_activity_log/version'

# rubocop:disable BlockLength
Gem::Specification.new do |spec|
  spec.name          = "certify_activity_log"
  spec.version       = CertifyActivityLog::VERSION::STRING
  spec.authors       = ["Fearless"]
  spec.email         = [""]

  spec.summary       = "Ruby Gem to wrap the Certify Activity Log API"
  spec.description   = "Ruby Gem to wrap the Certify Activity Log API (GIT_DESCRIBE)"
  spec.homepage      = "https://github.com/USSBA/certify_activity_log"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # NOTE: this may not work since uploading a gem should be done via `gem inabox [gemfile]`
    spec.metadata['allowed_push_host'] = 'http://geminabox.sba-one.net'
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "faker"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "vcr"

  spec.add_dependency "excon"
  spec.add_dependency "excon-rails"
  spec.add_dependency "json"

end
