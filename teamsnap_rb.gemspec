# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'teamsnap_rb/version'

Gem::Specification.new do |spec|
  spec.name          = "teamsnap_rb"
  spec.version       = TeamsnapRb::VERSION
  spec.authors       = ["Party Chicken", "Emily Dobervich", "Corey Purcell", "Zach Gardner", "Shane Emmons"]
  spec.email         = ["api@teamsnap.com"]
  spec.summary       = %q{A gem interact with TeamSnap's API}
  spec.description   = %q{}
  spec.homepage      = "http://www.teamsnap.com/api"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec", ">= 3.0.0"

  spec.add_dependency "faraday", "~> 0.9.0"
  spec.add_dependency "conglomerate", "~> 0.8.0"
end
