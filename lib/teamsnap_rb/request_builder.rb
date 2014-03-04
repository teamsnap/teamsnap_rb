require "openssl"

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
      elsif auth.client_id && auth.client_secret
        query_params = Hash[URI.decode_www_form(env.url.query || "")]
        query_params.merge!({
          hmac_client_id: auth.client_id,
          hmac_nonce: SecureRandom.uuid,
          hmac_timestamp: Time.now.to_i
        })
        env.url.query = URI.encode_www_form(query_params)

        message = env.url.to_s + (env.body || "")

        digest = OpenSSL::Digest.new('sha256')
        message_hash = digest.hexdigest(message)
        env.request_headers["X-Teamsnap-Hmac"] = OpenSSL::HMAC.hexdigest(digest, auth.client_secret, message_hash)
      end

      @app.call(env)
    end

    private

    attr_accessor :auth
  end

  Faraday::Request.register_middleware(
    :teamsnap_auth_middleware => lambda { TeamsnapAuthMiddleware }
  )
end
