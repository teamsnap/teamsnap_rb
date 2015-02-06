module TeamSnap
  class Client < Collection
    def initialize(url = "https://api.teamsnap.com/v3/", options = {})
      config = options.fetch(:config, Config.new)
      super(url, {}, config)
    end
  end
end
