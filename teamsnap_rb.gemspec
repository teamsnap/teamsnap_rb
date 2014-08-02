# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'teamsnap_rb/version'

Gem::Specification.new do |spec|
  spec.name          = "teamsnap_rb"
  spec.version       = TeamsnapRb::VERSION
  spec.authors       = ["Emily Dobervich", "Corey Purcell", "Zach Gardner"]
  spec.email         = ["api@teamsnap.com"]
  spec.summary       = %q{A gem interact with TeamSnap's API}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = ""

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"

  spec.add_dependency "faraday"
  spec.add_dependency "conglomerate"
end
