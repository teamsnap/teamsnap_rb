require "conglomerate"
require "json"
require "faraday"
require "securerandom"

require_relative "teamsnap_rb/version"
require_relative "teamsnap_rb/exceptions"
require_relative "teamsnap_rb/config"
require_relative "teamsnap_rb/request_builder"
require_relative "teamsnap_rb/link"
require_relative "teamsnap_rb/links_proxy"
require_relative "teamsnap_rb/queries_proxy"
require_relative "teamsnap_rb/item"
require_relative "teamsnap_rb/template"
require_relative "teamsnap_rb/models/event"
require_relative "teamsnap_rb/collection"
require_relative "teamsnap_rb/client"

module TeamsnapRb
  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config)
  end
end
