module TeamsnapRb
  class Client < Collection
    def initialize(url = "https://apiv3.teamsnap.com/")
      super(url, {})
    end
  end
end
