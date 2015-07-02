module TeamSnap
  class Configuration
    VALID_OPTIONS_KEYS = [
      :access_token,
      :client_id,
      :client_secret,
      :url,
      :proxy,
      :user_agent,
      :log_requests
    ]

    DEFAULT_URL = "https://api.teamsnap.com/v3/"
    DEFAULT_USER_AGENT = "TeamSnap Ruby Gem #{TeamSnap::VERSION}".freeze

    def configure
      yield self
    end
  end
end
