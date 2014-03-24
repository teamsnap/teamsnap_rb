module TeamsnapRb
  class QueriesProxy
    include Enumerable

    def initialize(queries, auth)
      self.auth = auth
      self.queries = queries.inject({}) do |h, query|
        h.tap do |hash|
          hash[query.rel.to_sym] = Query.new(query.href, query.data, auth)
        end
      end
    end

    def method_missing(method, *args)
      if query = queries[method.to_sym]
        query.get(*args)
      else
        super
      end
    end

    def respond_to?(method)
      queries.include?(method.to_sym) || super
    end

    def each
      queries.values.each do |query|
        yield query
      end
    end

    def rels
      queries.keys
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

    def get(query_parameters={})
      possible_params = data.map(&:name).map(&:to_sym)
      query_parameters.reject! { |key, value| !possible_params.include?(key) }

      if query_parameters.empty?
        raise(
          MissingQueryParameter,
          "You must provide at least one of the following parameters: #{possible_params}"
        )
      end

      Collection.new(url, query_parameters, auth)
    end

    private

    attr_accessor :url, :data, :auth
  end
end
