module TeamsnapRb
  class Collection
    include Enumerable

    def initialize(url, auth)
      self.auth = auth
      body = get(url).body
      self.collection_json = CollectionJSON.parse(body)
      self.items = collection_json.items.map do |item|
        Item.new(item, auth)
      end
    end

    def links
      @links ||= LinksProxy.new(collection_json.links, auth)
    end

    # def queries
    #   @queries ||= QueriesProxy.new(collection_json.queries, auth)
    # end

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

    private

    attr_accessor :collection_json, :auth, :items

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
