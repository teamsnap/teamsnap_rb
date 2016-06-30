module TeamSnap
  class Client

    class << self
      def set_faraday_client(url, token, client_id, client_secret)
        Faraday.new(
          :url => url,
          :parallel_manager => Typhoeus::Hydra.new
        ) do |c|
          c.request :multipart
          c.request :teamsnap_auth_middleware, {
            :token => token,
            :client_id => client_id,
            :client_secret => client_secret
          }
          c.adapter :typhoeus
        end
      end
    end

    attr_accessor :faraday_client

    def initialize(opts = {})
      c_url = opts.fetch(:url) {}
      c_token = opts.fetch(:token) {}
      c_id = opts.fetch(:client_id) {}
      c_secret = opts.fetch(:client_secret) {}

      self.faraday_client = TeamSnap::Client.set_faraday_client(
        c_url || TeamSnap.url,
        c_token,
        c_id || TeamSnap.client_id,
        c_secret || TeamSnap.client_secret
      )
    end

    def method_missing(method, *args, &block)
      self.faraday_client.send(method, *args, &block)
    end

    def api(method, klass, sent_args = {})
      TeamSnap::Api.run(
        self,
        method,
        klass,
        sent_args,
        TeamSnap::Api.template_args?(method)
      )
    end

  end
end
