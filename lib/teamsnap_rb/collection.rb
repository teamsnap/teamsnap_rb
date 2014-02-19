module TeamsnapRb
  class Collection
    include Enumerable

    PLURAL_TYPES_TO_SINGULAR = {
      "teams" => "Team",
      "users" => "User",
      "rosters" => "Roster"
    }

    def initialize(url, query_parameters={}, auth)
      self.auth = auth
      body = get(url, query_parameters).body
      self.collection_json = CollectionJSON.parse(body)
      self.item_types = Set.new

      self.items = collection_json.items.map do |item|
        Item.new(item, auth)
      end

      items.each do |item|
        item_types.add(item.type)
      end
    end

    def links
      @links ||= LinksProxy.new(collection_json.links, auth)
    end

    def queries
      @queries ||= QueriesProxy.new(collection_json.queries, auth)
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
      if item_types.include?(PLURAL_TYPES_TO_SINGULAR[method.to_s])
        where(:type => PLURAL_TYPES_TO_SINGULAR[method.to_s])
      else
        super
      end
    end

    def respond_to?(method)
      item_types.include?(PLURAL_TYPES_TO_SINGULAR[method])
    end

    private

    attr_accessor :collection_json, :auth, :items, :item_types

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
