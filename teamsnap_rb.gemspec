# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "teamsnap/version"

Gem::Specification.new do |spec|
  spec.name          = "teamsnap_rb"
  spec.version       = TeamSnap::VERSION
  spec.authors       = ["Shane Emmons", "Kyle Ries"]
  spec.email         = ["oss@teamsnap.com"]
  spec.summary       = %q{A gem to interact with TeamSnap's API}
  spec.description   = %q{A gem to interact with TeamSnap's API}
  spec.homepage      = "https://developer.teamsnap.com/"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "bundler", ">= 1.17.3"
  spec.add_development_dependency "rspec",   "~> 3.9"
  spec.add_development_dependency "vcr",     "~> 5.0"

  spec.add_dependency "faraday",  "~> 0.17", "< 1.0"
  spec.add_dependency "typhoeus", ">= 1.3", "< 1.5"
  spec.add_dependency "dry-inflector", "~> 0.2"
  spec.add_dependency "dry-types", "~> 1.0"
  spec.add_dependency "dry-struct", "~> 1.0"
end
