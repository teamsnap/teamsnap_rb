require "coveralls"
Coveralls.wear!

require "teamsnap"
require "pry"
require "webmock/rspec"
require "vcr"

RSpec.configure do |config|
  config.color = true
  config.order = "random"
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
end
