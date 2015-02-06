require "bundler/gem_tasks"
require "coveralls/rake/task"

Coveralls::RakeTask.new

desc "start an IRB session with teamsnap loaded"
task :console do
  require "pry"
  require "./lib/teamsnap"
  ARGV.clear
  Pry.start
end
