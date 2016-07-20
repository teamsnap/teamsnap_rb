module TeamSnap
  class AuthMiddleware < Faraday::Middleware
    def initialize(app, options)
      @options = options
      super(app)
    end

    def call(env)
      if token
        env[:request_headers].merge!({"Authorization" => "Bearer #{token}"})
      elsif client_id && client_secret
        query_params = Hash[URI.decode_www_form(env.url.query || "")]
          .merge({
            hmac_client_id: client_id,
            hmac_nonce: SecureRandom.uuid,
            hmac_timestamp: Time.now.to_i
          })
        env.url.query = URI.encode_www_form(query_params)

        env.request_headers["X-Teamsnap-Hmac"] = OpenSSL::HMAC.hexdigest(
          digest, client_secret, message_hash(env)
        )
      end

      @app.call(env)
    end

    def token
      @token ||= @options[:token]
    end

    def client_id
      @client_id ||= @options[:client_id]
    end

    def client_secret
      @client_secret ||= @options[:client_secret]
    end

    def digest
      OpenSSL::Digest.new("sha256")
    end

    def message_hash(env)
      digest.hexdigest(
        query_string(env) + message(env)
      )
    end

    def query_string(env)
      "/?" + env.url.query.to_s
    end

    def message(env)
      env.body.to_s || ""
    end
  end
end

Faraday::Request.register_middleware(
  :teamsnap_auth_middleware => -> { TeamSnap::AuthMiddleware }
)
