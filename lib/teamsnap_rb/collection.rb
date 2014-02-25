module TeamsnapRb
  class Collection
    include Enumerable

    TYPE_TO_CLASS = {
      "Event" => Event
    }

    def initialize(url, query_parameters={}, auth)
      self.auth = auth
      body = get(url, query_parameters).body
      self.collection_json = CollectionJSON.parse(body)
      self.items = collection_json.items.map do |item|
        type_name = item.data.find do |datum|
          datum.name == "type"
        end.value

        klass = TYPE_TO_CLASS[type_name] || Item
        klass.new(item, auth)
      end
    end

    def [](index)
      items[index]
    end

    def each
      items.each do |item|
        yield item
      end
    end

    def where(attribute_hash)
      CollectionWhereProxy.new(items).where(attribute_hash)
    end

    def href
      collection_json.href
    end

    def method_missing(method, *args)
      if links.respond_to?(method)
        links.send(method)
      elsif queries.respond_to?(method)
        queries.send(method, *args)
      else
        super
      end
    end

    def respond_to?(method)
      links.respond_to?(method) || queries.respond_to?(method)
    end

    private

    attr_accessor :collection_json, :auth, :items

    def links
      @links ||= LinksProxy.new(collection_json.links, auth)
    end

    def queries
      @queries ||= QueriesProxy.new(collection_json.queries, auth)
    end

    def get(url, query_parameters = {})
      RequestBuilder.new(auth, url).connection.get do |conn|
        query_parameters.each do |key, value|
          conn.params[key] = value
        end
      end
    end

    class CollectionWhereProxy
      include Enumerable

      def initialize(items)
        self.items = items
      end

      def [](index)
        items[index]
      end

      def each
        items.each do |item|
          yield item
        end
      end

      def where(attribute_hash)
        CollectionWhereProxy.new(find_all do |item|
          attribute_hash.keys.all? do |key|
            if item.respond_to?(key)
              attribute_hash[key] == item.send(key)
            else
              false
            end
          end
        end)
      end

      private

      attr_accessor :items
    end
  end
end
