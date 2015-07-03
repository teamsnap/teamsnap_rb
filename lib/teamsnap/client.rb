module TeamSnap
  class Client
    def initialize
      yield(configuration) if block_given?
    end

    def method_missing(method, *args, &block)
      #TODO: mutex/syncrhonize/just do once
      TeamSnap.init(connection)
      TeamSnap.const_get(Inflecto.camelize(method))
      #TODO: .me breaks
    end

    def respond_to?(method, include_all=false)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def connection
      @connection ||= begin
        Faraday.new(
          :url => configuration.url,
          :parallel_manager => Typhoeus::Hydra.new
        ) do |c|
          c.request :teamsnap_auth_middleware, {
            :token => configuration.token,
            :client_id => configuration.client_id,
            :client_secret => configuration.client_secret
          }
          c.response :logger if configuration.log_requests
          c.adapter :typhoeus
        end
      end
    end
  end
end
