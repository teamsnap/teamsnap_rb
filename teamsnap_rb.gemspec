# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "teamsnap/version"

Gem::Specification.new do |spec|
  spec.name          = "teamsnap_rb"
  spec.version       = TeamSnap::VERSION
  spec.authors       = ["Shane Emmons", "Kyle Ries"]
  spec.email         = ["api@teamsnap.com"]
  spec.summary       = %q{A gem interact with TeamSnap's API}
  spec.description   = %q{A gem interact with TeamSnap's API}
  spec.homepage      = "http://developer.teamsnap.com/"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 1.9.3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rspec",   "~> 3.2.0"
  spec.add_development_dependency "vcr",     "~> 2.9.3"

  spec.add_dependency "faraday",  "~> 0.9.1"
  spec.add_dependency "typhoeus", "~> 0.7.1"
  spec.add_dependency "oj",       "~> 2.11.4"
  spec.add_dependency "inflecto", "~> 0.0.2"
  spec.add_dependency "virtus",   "~> 1.0.4"
end
