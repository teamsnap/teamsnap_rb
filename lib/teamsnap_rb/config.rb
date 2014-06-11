module TeamsnapRb
  class Config
    attr_accessor :access_token, :client_id, :client_secret, :request_middleware, :response_middleware

    def initialize(access_token: nil, client_id: nil, client_secret: nil)
      self.access_token = access_token
      self.client_secret = client_secret
      self.client_id = client_id
      self.response_middleware = []
      self.request_middleware = []
    end
  end
end
