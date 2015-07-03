module TeamSnap
  class Client
    def initialize
      yield(configuration) if block_given?
    end

    def method_missing(method, *args, &block)
      #binding.pry
      #mutex/synchronize
      TeamSnap.init(connection)
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
          c.adapter :typhoeus
        end
      end
    end

  end
end
