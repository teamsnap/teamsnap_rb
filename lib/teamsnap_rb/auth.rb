module TeamsnapRb
  class Auth
    def initialize(access_token, client_id, client_secret)
      self.access_token = access_token
      self.client_id = client_id
      self.client_secret = client_secret
    end

    def headers
      if access_token
        { "X-TEAMSNAP-ACCESS-TOKEN" => access_token }
      else
        {}
      end
    end

    private

    attr_accessor :access_token, :client_id, :client_secret
  end
end
