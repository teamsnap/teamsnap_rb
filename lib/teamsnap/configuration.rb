module TeamSnap
  class Configuration
    DEFAULT_URL = "https://api.teamsnap.com/v3/"
    DEFAULT_USER_AGENT = "TeamSnap Ruby Gem #{TeamSnap::VERSION}"

    attr_accessor :token, :client_id, :client_secret, :url, :user_agent,
      :proxy, :log_requests

    def initialize
      self.url = DEFAULT_URL
      self.user_agent = DEFAULT_USER_AGENT
      self.log_requests = false
    end
  end
end
