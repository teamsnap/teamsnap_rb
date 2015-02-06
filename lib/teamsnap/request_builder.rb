require "openssl"
require "faraday"
require "securerandom"

module TeamSnap
  class RequestBuilder
    attr_reader :connection

    def initialize(config, url)
      self.config = config
      self.connection = Faraday::Connection.new(:url => url) do |faraday|
        config.request_middleware.each do |m|
          faraday.request(m)
        end

        config.response_middleware.each do |m|
          faraday.response(m)
        end

        faraday.request :teamsnap_config_middleware, config
        faraday.adapter Faraday.default_adapter
      end
    end

    private

    attr_accessor :config
    attr_writer :connection
  end

  class TeamsnapAuthMiddleware < Faraday::Middleware
    def initialize(app, *args, &block)
      self.config = args[0]
      super(app)
    end

    def call(env)
      if config.access_token
        env.request_headers["X-Teamsnap-Access-Token"] = config.access_token
      elsif config.authorization
        env.request_headers["Authorization"] = "Bearer #{config.authorization}"
      elsif config.client_id && config.client_secret
        query_params = Hash[URI.decode_www_form(env.url.query || "")]
        query_params.merge!({
          hmac_client_id: config.client_id,
          hmac_nonce: SecureRandom.uuid,
          hmac_timestamp: Time.now.to_i
        })
        env.url.query = URI.encode_www_form(query_params)

        message = "/?" + env.url.query.to_s + (env.body || "")
        digest = OpenSSL::Digest.new("sha256")
        message_hash = digest.hexdigest(message)

        env.request_headers["X-Teamsnap-Hmac"] = OpenSSL::HMAC.hexdigest(digest, config.client_secret, message_hash)
      end

      @app.call(env)
    end

    private

    attr_accessor :config
  end

  Faraday::Request.register_middleware(
    :teamsnap_config_middleware => lambda { TeamsnapAuthMiddleware }
  )
end
