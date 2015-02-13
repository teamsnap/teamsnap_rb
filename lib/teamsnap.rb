require "faraday"
require "typhoeus"
require "typhoeus/adapters/faraday"
require "oj"
require "inflector"
require "virtus"
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

      self.client = Faraday.new(:url => opts.fetch(:url)) do |c|
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
      return if EXCLUDED_RELS.include?(link.fetch(:rel))

      rel = link.fetch(:rel)
      href = link.fetch(:href)
      client = @client
      name = rel.singularize.pascalize

      TeamSnap.const_set(
        name, Class.new { include TeamSnap.collection(client, href) }
      ) unless TeamSnap.const_defined?(name)
    end

    def register_endpoint(obj, endpoint, opts)
      rel = endpoint.fetch(:rel)
      href = endpoint.fetch(:href)
      valid_args = endpoint.fetch(:data)
        .map { |datum| datum.fetch(:name).to_sym }
      via = opts.fetch(:via)

      obj.define_singleton_method(rel) do |*args|
        args = Hash[*args]

        unless args.all? { |arg, _| valid_args.include?(arg) }
          raise ArgumentError,
            "Invalid argument(s). Valid argument(s) are #{valid_args.inspect}"
        end

        TeamSnap.send(:run, via, href, args)
      end
    end

    def run(via, href, args)
      resp = client.send(via, href, args)

      if resp.status == 200
        Oj.load(resp.body)
          .fetch(:collection)
          .fetch(:items) { [] }
          .map { |item|
            data = item
              .fetch(:data)
              .map { |datum|
                name  = datum.fetch(:name)
                value = datum.fetch(:value)
                type  = datum.fetch(:type) { :default }

                value = DateTime.parse(value) if value && type == "DateTime"

                [name, value]
              }
              .inject({}) { |h, (k, v)| h[k] = v; h }
            type = item
              .fetch(:data)
              .find { |datum| datum.fetch(:name) == "type" }
              .fetch(:value)
            cls = TeamSnap.const_get(type.pascalize)
            unless cls.include?(Virtus::Model::Core)
              cls.class_eval do
                include Virtus.value_object

                values do
                  attribute :href, String
                  data.each { |name, value| attribute name, value.class }
                end
              end
            end
            cls.new(data).tap { |obj|
              obj.send(:load_links, item.fetch(:links))
            }
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
    private

    def client
      self.class.instance_variable_get(:@client)
    end

    def load_links(links)
      links.each do |link|
        next if EXCLUDED_RELS.include?(link.fetch(:rel))

        rel = link.fetch(:rel)
        href = link.fetch(:href)
        is_singular = rel == rel.singularize

        define_singleton_method(rel) {
          coll = TeamSnap.send(:run, :get, href, {})
          coll.size == 1 && is_singular ? coll.first : coll
        }
      end
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
        .each { |endpoint|
          TeamSnap.send(:register_endpoint, self, endpoint, :via => :get)
        }

      collection
        .fetch(:commands) { [] }
        .each { |endpoint|
          TeamSnap.send(:register_endpoint, self, endpoint, :via => :post)
        }

      enable_find if respond_to?(:search)
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

if __FILE__ == $0
  TeamSnap.init("")
  require"pry";binding.pry
end
