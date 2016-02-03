module TeamSnap
  class Client

    class << self
      def set_faraday_client(url, token, client_id, client_secret)
        Faraday.new(
          :url => url,
          :parallel_manager => Typhoeus::Hydra.new
        ) do |c|
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

    def initialize(opts = {}, c_id = nil, c_secret = nil)
      self.faraday_client = TeamSnap::Client.set_faraday_client(
        TeamSnap.url,
        opts.fetch(:token, nil),
        c_id || TeamSnap.client_id,
        c_secret || TeamSnap.client_secret
      )
    end

    def method_missing(method, *args, &block)
      self.faraday_client.send(method, *args, &block)
    end

    def api(klass, via, args = {}, template_args = false)
      href = klass.parsed_collection.fetch(:href) { "" }
      case via
      when :delete, :get
        TeamSnap::Api.run(self, via, href+"/#{args}", {}, template_args)
      when :patch
        TeamSnap::Api.run(self, via, href+"/#{args.fetch(:id)}", args.except(:id), template_args)
      when :post
        TeamSnap::Api.run(self, via, href, args, template_args)
      when :search
        TeamSnap::Api.run(self, :get, href+"/search", args, template_args)
      else
        TeamSnap::Api.run(self, :post, href+"/#{via}", args, template_args)
      end
    end

  end
end