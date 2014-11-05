module TeamsnapRb
  class Config
    attr_accessor :access_token, :client_id, :client_secret, :request_middleware, :response_middleware

    def initialize
      self.access_token = nil
      self.client_secret = nil
      self.client_id = nil
      self.response_middleware = []
      self.request_middleware = []
    end
  end
end
