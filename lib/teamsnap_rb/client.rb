module TeamsnapRb
  class Client < Collection
    def initialize(url = "https://apiv3.teamsnap.com/", options = {})
      config = options.fetch(:config, Config.new)
      super(url, {}, config)
    end
  end
end
