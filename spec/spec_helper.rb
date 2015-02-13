require "simplecov"
require "coveralls"

SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "vendor"
end

RSpec.configure do |c|
  c.expose_dsl_globally = false
  c.order = "random"
  c.backtrace_inclusion_patterns = []
end
