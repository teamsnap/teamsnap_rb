module TeamsnapRb
  class RequestBuilder
    attr_reader :connection

    def initialize(auth, url)
      self.auth = auth
      self.connection = Faraday::Connection.new(:url => url) do |faraday|
        faraday.request :teamsnap_auth_middleware, auth
        faraday.adapter Faraday.default_adapter
      end
    end

    private

    attr_accessor :auth
    attr_writer :connection
  end

  class TeamsnapAuthMiddleware < Faraday::Middleware
    def initialize(app, *args, &block)
      self.auth = args[0]
      super(app)
    end

    def call(env)
      if auth.access_token
        env.request_headers["X-Teamsnap-Access-Token"] = auth.access_token
      end

      @app.call(env)
    end

    private

    attr_accessor :auth
  end

  Faraday::Request.register_middleware :request,
    :teamsnap_auth_middleware => lambda { TeamsnapAuthMiddleware }
end
