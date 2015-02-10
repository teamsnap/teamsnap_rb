require "faraday"
require "typhoeus"
require "typhoeus/adapters/faraday"
require "oj"
require "inflector"
require "date"

require "teamsnap/version"

class String
  include Inflector::CoreExtensions::String
end

Oj.default_options = {
  :mode => :compat,
  :symbol_keys => true,
  :class_cache => true
}

Faraday::Request.register_middleware(
  :teamsnap_auth_middleware => -> { TeamSnap::AuthMiddleware }
)

module TeamSnap
  EXCLUDED_RELS = [
    "me", "apiv2_root", "root", "self"
  ]
  DEFAULT_URL = "http://127.0.0.1:3000"
  DEFAULT_ERROR_MESSAGE = "Unknown API Error. Contact Maintainer (https://github.com/teamsnap/teamsnap_rb/issues)."
  Error = Class.new(StandardError)
  NotFound = Class.new(TeamSnap::Error)

  def self.collection(conn, href)
    Module.new do
      define_singleton_method(:included) do |descendant|
        descendant.send(:include, TeamSnap::Item)
        descendant.instance_variable_set(:@conn, conn)
        descendant.instance_variable_set(:@href, href)
        descendant.extend(TeamSnap::Collection)
        descendant.send(:load_collection)
      end
    end
  end

  class AuthMiddleware < Faraday::Middleware
    def initialize(app, options)
      super(app)
      @options = options
    end

    def call(env)
      token = @options.fetch(:token) {
        raise ArgumentError, "You must supply an auth token to #{self.class}"
      }
      env[:request_headers].merge!({
        "Authorization" => "Bearer #{token}",
        "Content-Type" => "application/json"
      })

      @app.call(env)
    end
  end

  module Item
    attr_reader :href

    def initialize(item)
      self.item = item
      self.href = item[:href]

      load_data
      load_links
    end

    def inspect
      "#<#{self.class.name} :id => #{self.id}>"
    end

    private

    attr_accessor :item
    attr_writer :href

    def conn
      self.class.instance_variable_get(:@conn)
    end

    def load_data
      item[:data].each { |datum|
        name  = datum.fetch(:name)
        value = datum.fetch(:value)
        type  = datum.fetch(:type) { :default }

        value = DateTime.parse(value) if type == "DateTime" && value

        define_singleton_method(name) { value }
      }
    end

    def load_links
      item[:links].each { |link|
        rel = link.fetch(:rel)
        href = link.fetch(:href)

        define_singleton_method(rel) { href }
      }
    end
  end

  module Collection
    def href
      self.instance_variable_get(:@href)
    end

    private

    def conn
      self.instance_variable_get(:@conn)
    end

    def load_collection
      resp = conn.get(href)
      collection = Oj.load(resp.body)
        .fetch(:collection) { {} }

      collection
        .fetch(:queries) { [] }
        .each { |endpoint| register_endpoint(endpoint, :via => :get) }

      collection
        .fetch(:commands) { [] }
        .each { |endpoint| register_endpoint(endpoint, :via => :post) }

      enable_find if respond_to?(:search)
    end

    def register_endpoint(endpoint, opts = {})
      rel = endpoint.fetch(:rel)
      href = endpoint.fetch(:href)
      valid_args = endpoint.fetch(:data)
        .lazy
        .map { |datum| datum.fetch(:name) }
        .map(&:to_sym)
        .to_a
      via = opts.fetch(:via)

      define_singleton_method(rel) do |*args|
        args = Hash[*args]

        unless args.all? { |arg, _| valid_args.include?(arg) }
          raise ArgumentError,
            "Invalid argument(s). Valid argument(s) are #{valid_args.inspect}"
        end

        resp = conn.send(via, href, args)

        if resp.status == 200
          Oj.load(resp.body)
            .fetch(:collection) { {} }
            .fetch(:items) { [] }
            .map { |item|
              type = item
                .fetch(:data)
                .find { |datum| datum.fetch(:name) == "type" }
                .fetch(:value)
              cls = Kernel.const_get("TeamSnap::#{type.singularize.pascalize}")
              cls.new(item)
            }
        else
          error_message = Oj.load(resp.body)
            .fetch(:collection) { {} }
            .fetch(:error) { {} }
            .fetch(:message) { DEFAULT_ERROR_MESSAGE }
          raise TeamSnap::Error, error_message
        end
      end
    end

    def enable_find
      define_singleton_method(:find) do |id|
        search(:id => id).first.tap do |object|
          unless object
            raise TeamSnap::NotFound,
              "Could not find a #{self} with an id of '#{id}'."
          end
        end
      end
    end
  end

  class Client
    def initialize(token, opts = {})
      self.token = token
      self.opts = opts
      opts[:url] ||= DEFAULT_URL

      self.conn = Faraday.new(:url => opts[:url]) do |conf|
        conf.request :teamsnap_auth_middleware, {:token => token}
        conf.adapter :typhoeus
      end

      load_root
    end

    private

    attr_accessor :token, :opts, :conn

    def load_root
      resp = conn.get("/")

      # need to account for non-200 status

      collection = Oj.load(resp.body)
        .fetch(:collection) { {} }

      collection
        .fetch(:links) { [] }
        .each { |link| classify_rel(link) }

      enable_bulk_load(
        collection
          .fetch(:queries) { [] }
          .find { |query| query[:rel] == "bulk_load" }
      )
    end

    def classify_rel(link)
      return if EXCLUDED_RELS.include?(link[:rel])

      rel = link[:rel]
      href = link[:href]
      conn = @conn
      name = rel.singularize.pascalize

      TeamSnap.const_set(
        name, Class.new { include TeamSnap.collection(conn, href) }
      )
    end

    def enable_bulk_load(query)
      href = query.fetch(:href)

      define_singleton_method(:bulk_load) do |*args|
        args = Hash[*args]
        resp = conn.get(href, args)

        # need to account for non-200 status

        if resp.status == 200
          Oj.load(resp.body)
            .fetch(:collection) { {} }
            .fetch(:items) { [] }
            .map { |item|
              type = item
                .fetch(:data)
                .find { |datum| datum.fetch(:name) == "type" }
                .fetch(:value)
              cls = Kernel.const_get("TeamSnap::#{type.singularize.pascalize}")
              cls.new(item)
            }
        else
          error_message = Oj.load(resp.body)
            .fetch(:collection) { {} }
            .fetch(:error) { {} }
            .fetch(:message) { DEFAULT_ERROR_MESSAGE }
          raise TeamSnap::Error, error_message
        end
      end
    end
  end
end

if __FILE__ == $0
  TeamSnap::Client.new("").tap do |client|
    require "pry"; binding.pry
  end
end
