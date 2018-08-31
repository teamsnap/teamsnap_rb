%w(
    faraday typhoeus typhoeus/adapters/faraday oj inflecto virtus
    date securerandom
  ).each { |x| require x }

%w(
    config/inflecto config/oj teamsnap/version teamsnap/api
    teamsnap/auth_middleware teamsnap/client teamsnap/collection teamsnap/item
    teamsnap/response teamsnap/structure
  ).each { |x| require_relative x }

module TeamSnap
  EXCLUDED_RELS = %w(me apiv2_root root self dude sweet random xyzzy schemas
                     authorization plans_all tsl_photos)
  DEFAULT_URL = "https://apiv3.teamsnap.com"
  Error = Class.new(StandardError)
  NotFound = Class.new(TeamSnap::Error)
  InitializationError = Class.new(TeamSnap::Error)

  class << self
    attr_accessor :client_id, :client_secret, :root_client, :token, :url,
      :headers

    def init(opts = {})
      unless opts[:token] || (opts[:client_id] && opts[:client_secret])
        raise ArgumentError.new("You must provide a :token or :client_id and :client_secret pair to '.init'")
      end

      ##   setup variables required
      self.client_id = opts.fetch(:client_id) {}
      self.client_secret = opts.fetch(:client_secret) {}
      self.token = opts.fetch(:token) {}
      self.url = opts.fetch(:url) { DEFAULT_URL }

      ##   create universally accessible TeamSnap.root_client
      self.root_client = TeamSnap::Client.new(:token => token)

      ##   include any feature headers
      if opts[:headers]
        if headers = opts.fetch(:headers)
          self.root_client.headers = self.root_client.headers.merge(headers)
        end
      end

      ##   Make the apiv3 root call. collection is parsed JSON
      collection = TeamSnap.run(root_client, :get, self.url, {}) do
        self.root_client = nil
        raise TeamSnap::InitializationError
      end

      ##   Setup Dynamic Classes from the collection
      TeamSnap::Structure.init(root_client, collection)

      ##   Queries and Commands parsing for shortcut methods
      TeamSnap::Collection.apply_endpoints(self, collection) && true
    end

    def run(client, via, href, args = {}, &block)
      timeout_error = block || default_timeout_error
      resp = client_send(client, via, href, args)
      unless resp.status == 204
        TeamSnap::Response.load_collection(resp)
      end
    rescue Faraday::TimeoutError
      timeout_error.call
    end

    def default_timeout_error
      -> {
        warn("Connection to API failed with TimeoutError")
        {:links => []}
      }
    end

    def client_send(client, via, href, args)
      case via
      when :get, :delete
        client.send(via, href, args)
      when :patch, :post
        client.send(via, href) do |req|
          if use_multipart?(args)
            req.body = args
          else
            req.body = Oj.dump(args)
          end
        end
      else
        raise TeamSnap::Error.new("Don't know how to run `#{via}`")
      end
    end

    private

    def use_multipart?(args)
      args.values.any? { |a| is_file?(a) }
    end

    def is_file?(arg)
      arg.respond_to?(:path) && File.file?(arg)
    end
  end
end
