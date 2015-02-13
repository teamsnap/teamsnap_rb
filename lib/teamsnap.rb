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

  class << self
    def collection(href)
      Module.new do
        define_singleton_method(:included) do |descendant|
          descendant.send(:include, TeamSnap::Item)
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

    def run(via, href, args = {})
      resp = client.send(via, href, args)

      if resp.status == 200
        Oj.load(resp.body)
          .fetch(:collection)
      else
        error_message = Oj.load(resp.body)
          .fetch(:collection)
          .fetch(:error)
          .fetch(:message)
        raise TeamSnap::Error, error_message
      end
    end

    def load_items(collection)
      collection
        .fetch(:items) { [] }
        .map { |item|
          data = parse_data(item)
          type = type_of(item)
          cls  = load_class(type, data)

          cls.new(data).tap { |obj|
            obj.send(:load_links, item.fetch(:links))
          }
        }
    end

    def apply_endpoints(obj, collection)
      collection
        .fetch(:queries) { [] }
        .each { |endpoint| register_endpoint(obj, endpoint, :via => :get) }

      collection
        .fetch(:commands) { [] }
        .each { |endpoint| register_endpoint(obj, endpoint, :via => :post) }
    end

    private

    attr_accessor :client

    def load_root
      collection = TeamSnap.run(:get, "/")

      collection
        .fetch(:links)
        .each { |link| classify_rel(link) }

      apply_endpoints(self, collection)
    end

    def classify_rel(link)
      return if EXCLUDED_RELS.include?(link.fetch(:rel))

      rel = link.fetch(:rel)
      href = link.fetch(:href)
      name = rel.singularize.pascalize

      TeamSnap.const_set(
        name, Class.new { include TeamSnap.collection(href) }
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

        TeamSnap.load_items(
          TeamSnap.run(via, href, args)
        )
      end
    end

    def parse_data(item)
      item
        .fetch(:data)
        .map { |datum|
          name = datum.fetch(:name)
          value = datum.fetch(:value)
          type = datum.fetch(:type) { :default }

          value = DateTime.parse(value) if value && type == "DateTime"

          [name, value]
        }
        .inject({}) { |h, (k, v)| h[k] = v; h }
    end

    def type_of(item)
      item
        .fetch(:data)
        .find { |datum| datum.fetch(:name) == "type" }
        .fetch(:value)
    end

    def load_class(type, data)
      TeamSnap.const_get(type.pascalize).tap { |cls|
        unless cls.include?(Virtus::Model::Core)
          cls.class_eval do
            include Virtus.value_object

            values do
              attribute :href, String
              data.each { |name, value| attribute name, value.class }
            end
          end
        end
      }
    end
  end

  module Item
    private

    def load_links(links)
      links.each do |link|
        next if EXCLUDED_RELS.include?(link.fetch(:rel))

        rel = link.fetch(:rel)
        href = link.fetch(:href)
        is_singular = rel == rel.singularize

        define_singleton_method(rel) {
          coll = TeamSnap.load_items(
            TeamSnap.run(:get, href)
          )
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

    def load_collection
      collection = TeamSnap.run(:get, href)

      TeamSnap.apply_endpoints(self, collection)
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
  # TeamSnap.init("5ba070d04728e3de7f4f051ab3b00f98928949b4fefad135b54332ef3d712752")
  TeamSnap.init("")
  require"pry";binding.pry
end
