module TeamsnapRb
  class QueriesProxy
    def initialize(queries, auth)
      self.auth = auth
      self.queries = queries
    end

    def method_missing(method, *args)
      if query = queries.find { |q| q.rel == method.to_s }
         Query.build(query, auth, *args)
      else
        super
      end
    end

    def respond_to?(method)
      if queries.find { |q| q.rel == method.to_s }
        true
      else
        false
      end
    end

    private

    attr_accessor :queries, :auth
  end

  class Query

    MissingQueryParameter = Class.new(StandardError)

    def initialize(url, data, auth)
      self.url = url
      self.data = data
      self.auth = auth
    end

    def self.build(query, auth, args)
      new(query.href, query.data, auth).get(args)
    end

    def get(query_parameters={})
      required_params = data.map(&:name).map(&:to_sym)
      missing_params = required_params - query_parameters.keys
      raise MissingQueryParameter, "missing required parameters #{missing_params}" if missing_params.any?

      Collection.new(url, query_parameters, auth)
    end

    private

    attr_accessor :url, :data, :auth
  end
end
