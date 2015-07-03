module TeamSnap
  class Configuration
    DEFAULT_URL = "https://api.teamsnap.com/v3/"
    DEFAULT_USER_AGENT = "TeamSnap Ruby Gem #{TeamSnap::VERSION}"

    attr_accessor :token, :client_id, :client_secret, :url, :user_agent, :proxy

    def initialize
      self.url = DEFAULT_URL
      self.user_agent = DEFAULT_USER_AGENT
    end
  end
end
