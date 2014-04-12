module TeamsnapRb
  class Client < Collection
    def initialize(url = "https://apiv3.teamsnap.com/", access_token: nil, client_id: nil, client_secret: nil)
      auth = Auth.new(access_token, client_id, client_secret)
      super(url, {}, auth)
    end
  end
end
