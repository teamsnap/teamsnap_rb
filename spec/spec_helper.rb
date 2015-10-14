require "simplecov"
require "coveralls"

SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "vendor"
end

require "vcr"

ROOT_TEST_URL = "http://localhost:3000"

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :typhoeus
  c.configure_rspec_metadata!
  c.default_cassette_options = {
    :match_requests_on => [
      :method,
      VCR.request_matchers.uri_without_params(
        :hmac_client_id, :hmac_nonce, :hmac_timestamp
      )
    ]
  }
  c.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end
end

RSpec.configure do |c|
  c.expose_dsl_globally = false
  c.order = "random"
  c.backtrace_inclusion_patterns = []
end
