module TeamsnapRb
  class CollectionBase
    include Enumerable

    def initialize(url, auth)
      self.auth = auth
      self.collection_json = CollectionJSON.parse(body)
    end

    def links
      @links ||= LinksProxy.new(collection_json.links, auth)
    end

    # def queries
    #   @queries ||= QueriesProxy.new(collection_json.queries, auth)
    # end

    def [](index)
      Item.new(collection_json.items[index], auth)
    end

    def each
      collection_json.items.each do |item|
        yield Item.new(item, auth)
      end
    end

    def where(attribute_hash)
      CollectionBaseWhereProxy.new(self.to_a).where(attribute_hash)
    end

    private

    attr_accessor :collection_json, :auth

    def get(url, query_parameters = {})
      Faraday.get do |conn|
        auth.headers.each do |key, value|
          conn.headers[key] = value
        end

        query_parameters.each do |key, value|
          conn.params[key] = value
        end

        conn.url(url)
      end
    end

    class CollectionBaseWhereProxy
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
        CollectionBaseWhereProxy.new(find_all do |item|
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
