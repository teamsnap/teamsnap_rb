require "coveralls"
Coveralls.wear!

# require "vcr"

# VCR.configure do |c|
#   c.cassette_library_dir = "spec/cassettes"
#   c.hook_into :webmock
#   c.configure_rspec_metadata!
# end

RSpec.configure do |c|
  c.expose_dsl_globally = false
  c.order = "random"
  c.backtrace_inclusion_patterns = []
end
