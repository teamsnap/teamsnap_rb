module TeamSnap
  class Client
    class << self
      def set_faraday_client(url, token, client_id, client_secret)
        Faraday.new(
          :url => url,
          :parallel_manager => Typhoeus::Hydra.new
        ) do |con|
          con.request :multipart
          con.request :teamsnap_auth_middleware, {
            :token => token,
            :client_id => client_id,
            :client_secret => client_secret
          }
          con.adapter :typhoeus
        end
      end
    end

    attr_accessor :faraday_client

    def initialize(opts = {})
      con_url = opts.fetch(:url) {}
      con_token = opts.fetch(:token) {}
      con_id = opts.fetch(:client_id) {}
      con_secret = opts.fetch(:client_secret) {}

      self.faraday_client = TeamSnap::Client.set_faraday_client(
        con_url || TeamSnap.url,
        con_token,
        con_id || TeamSnap.client_id,
        con_secret || TeamSnap.client_secret,
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
