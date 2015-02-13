require "faraday"
require "typhoeus"
require "typhoeus/adapters/faraday"
require "oj"
require "inflector"
require "date"

require_relative "teamsnap/version"

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
  Error = Class.new(StandardError)
  NotFound = Class.new(TeamSnap::Error)

  class << self
    def collection(client, href)
      Module.new do
        define_singleton_method(:included) do |descendant|
          descendant.send(:include, TeamSnap::Item)
          descendant.instance_variable_set(:@client, client)
          descendant.instance_variable_set(:@href, href)
          descendant.extend(TeamSnap::Collection)
          descendant.send(:load_collection)
        end
      end
    end

    def init(token, opts = {})
      opts[:url] ||= DEFAULT_URL

      self.client = Faraday.new(:url => opts[:url]) do |c|
        c.request :teamsnap_auth_middleware, {:token => token}
        c.adapter :typhoeus
      end

      load_root

      true
    end

    private

    attr_accessor :client

    def load_root
      resp = client.get("/")

      # need to account for non-200 status

      collection = Oj.load(resp.body)
        .fetch(:collection)

      collection
        .fetch(:links)
        .each { |link| classify_rel(link) }

      collection
        .fetch(:queries)
        .each { |endpoint| register_endpoint(self, endpoint, :via => :get) }
    end

    def classify_rel(link)
      return if EXCLUDED_RELS.include?(link[:rel])

      rel = link[:rel]
      href = link[:href]
      client = @client
      name = rel.singularize.pascalize

      self.const_set(
        name, Class.new { include TeamSnap.collection(client, href) }
      ) unless self.const_defined?(name)
    end

    def register_endpoint(obj, endpoint, opts)
      rel = endpoint.fetch(:rel)
      href = endpoint.fetch(:href)
      valid_args = endpoint.fetch(:data)
        .lazy
        .map { |datum| datum.fetch(:name) }
        .map(&:to_sym)
        .to_a
      via = opts.fetch(:via)

      obj.define_singleton_method(rel) do |*args|
        args = Hash[*args]

        unless args.all? { |arg, _| valid_args.include?(arg) }
          raise ArgumentError,
            "Invalid argument(s). Valid argument(s) are #{valid_args.inspect}"
        end

        resp = client.send(via, href, args)

        if resp.status == 200
          Oj.load(resp.body)
            .fetch(:collection)
            .fetch(:items) { [] }
            .map { |item|
              type = item
                .fetch(:data)
                .find { |datum| datum.fetch(:name) == "type" }
                .fetch(:value)
              cls = Kernel.const_get("TeamSnap::#{type.pascalize}")
              cls.new(item)
            }
        else
          error_message = Oj.load(resp.body)
            .fetch(:collection)
            .fetch(:error)
            .fetch(:message)
          raise TeamSnap::Error, error_message
        end
      end
    end
  end

  class AuthMiddleware < Faraday::Middleware
    def initialize(app, options)
      super(app)
      @options = options
    end

    def call(env)
      token = @options.fetch(:token)
      env[:request_headers].merge!({"Authorization" => "Bearer #{token}"})

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
      "#<#{self.class.name} id=#{self.id}>"
    end

    private

    attr_accessor :item
    attr_writer :href

    def client
      self.class.instance_variable_get(:@client)
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
        is_singular = rel == rel.singularize

        define_singleton_method(rel) {
          resp = client.get(href)

          coll = Oj.load(resp.body)
            .fetch(:collection)
            .fetch(:items) { [] }
            .map { |item|
              type = item
                .fetch(:data)
                .find { |datum| datum.fetch(:name) == "type" }
                .fetch(:value)
              cls = Kernel.const_get("TeamSnap::#{type.pascalize}")
              cls.new(item)
            }
          coll.size == 1 && is_singular ? coll.first : coll
        }
      }
    end
  end

  module Collection
    def href
      self.instance_variable_get(:@href)
    end

    private

    def client
      self.instance_variable_get(:@client)
    end

    def load_collection
      resp = client.get(href)
      collection = Oj.load(resp.body)
        .fetch(:collection)

      collection
        .fetch(:queries)
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

        resp = client.send(via, href, args)

        if resp.status == 200
          Oj.load(resp.body)
            .fetch(:collection)
            .fetch(:items) { [] }
            .map { |item|
              type = item
                .fetch(:data)
                .find { |datum| datum.fetch(:name) == "type" }
                .fetch(:value)
              cls = Kernel.const_get("TeamSnap::#{type.pascalize}")
              cls.new(item)
            }
        else
          error_message = Oj.load(resp.body)
            .fetch(:collection)
            .fetch(:error)
            .fetch(:message)
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
end
