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
  EXCLUDED_RELS = %w(me apiv2_root root self dude sweet random xyzzy schemas)
  DEFAULT_URL = "https://apiv3.teamsnap.com"
  Error = Class.new(StandardError)
  NotFound = Class.new(TeamSnap::Error)

  class << self
    attr_accessor :client_id, :client_secret, :root_client, :token, :url

    def init(opts = {})
      ##   setup variables required
      self.client_id = opts.fetch(:client_id) {}
      self.client_secret = opts.fetch(:client_secret) {}
      self.token = opts.fetch(:token) {}
      self.url = opts.fetch(:url) {}

      ##   create universally accessible TeamSnap.root_client
      self.root_client = TeamSnap::Client.new(:token => token)

      ##   Make the apiv3 root call. collection is parsed JSON
      collection = TeamSnap.run_init(:get, "/", {})

      ##   Setup Dynamic Classes from the collection
      TeamSnap::Structure.init(root_client, collection)

      ##   Queries and Commands parsing for shortcut methods
      TeamSnap::Collection.apply_endpoints(self, collection) && true
    end

    def run_init(via, href, args = {}, opts = {})
      begin
        resp = client_send(root_client, via, href, args)
      rescue Faraday::TimeoutError
        warn("Connection to API failed. Initializing with empty class structure")
        {:links => []}
      else
        TeamSnap::Response.load_collection(resp, via)
      end
    end

    def run(client, via, href, args = {})
      resp = client_send(client, via, href, args)
      TeamSnap::Response.load_collection(resp, via)
    end

    def client_send(client, via, href, args)
      case via
      when :get, :delete
        client.send(via, href, args)
      when :patch, :post
        client.send(via, href) do |req|
          req.body = Oj.dump(args)
        end
      else
        raise TeamSnap::Error.new("Don't know how to run `#{via}`")
      end
    end

  end
end
