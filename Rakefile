require "bundler/gem_tasks"
require 'coveralls/rake/task'

Coveralls::RakeTask.new

desc "start an IRB session with teamsnap_rb loaded"
task :console do
  require "pry"
  require "./lib/teamsnap_rb"
  ARGV.clear
  Pry.start
end
