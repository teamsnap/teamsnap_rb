require "conglomerate"
require "json"
require "faraday"
require "securerandom"

require_relative "teamsnap/version"
require_relative "teamsnap/config"
require_relative "teamsnap/request_builder"
require_relative "teamsnap/link"
require_relative "teamsnap/links_proxy"
require_relative "teamsnap/queries_proxy"
require_relative "teamsnap/item"
require_relative "teamsnap/template"
require_relative "teamsnap/command"
require_relative "teamsnap/commands"
require_relative "teamsnap/models/event"
require_relative "teamsnap/collection"
require_relative "teamsnap/client"

module TeamSnap
  HttpError = Class.new(StandardError)
end
