require "rubygems"
require "bundler/gem_tasks"
require "rake/clean"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
end
task :default => :spec

desc "start an IRB session with teamsnap loaded"
task :console do
  require "pry"
  require "./lib/teamsnap"
  ARGV.clear
  Pry.start
end
