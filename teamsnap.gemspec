# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "teamsnap/version"

Gem::Specification.new do |spec|
  spec.name          = "teamsnap"
  spec.version       = TeamSnap::VERSION
  spec.authors       = ["Party Chicken"]
  spec.email         = ["api@teamsnap.com"]
  spec.summary       = %q{A gem interact with TeamSnap's API}
  spec.description   = %q{}
  spec.homepage      = "http://www.teamsnap.com/api"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 1.9.3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.4.2"
  spec.add_development_dependency "rspec", "~> 3.2.0"
  spec.add_development_dependency "webmock", "~> 1.20.4"
  spec.add_development_dependency "vcr", "~> 2.9.3"

  spec.add_dependency "faraday", "~> 0.9.1"
  spec.add_dependency "typhoeus", "~> 0.7.1"
  spec.add_dependency "conglomerate", "~> 0.16.0"
end
