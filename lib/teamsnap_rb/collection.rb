module TeamsnapRb
  class Collection
    include Enumerable

    attr_reader :errors

    TYPE_TO_CLASS = {
      "Event" => Event
    }

    def initialize(url, query_parameters, config, options = {})
      request = options.fetch(:request, nil)

      self.config = config
      data = request || get(url, query_parameters)
      self.errors = []
      self.url = data.env["url"]
      body = data.body

      if data.success?
        deserializer = Conglomerate::TreeDeserializer.new(JSON.parse(body))
        self.collection_json = deserializer.deserialize
        self.items = collection_json.items.map do |item|
          type_name = item.data.find do |datum|
            datum.name == "type"
          end.value

          klass = TYPE_TO_CLASS[type_name] || Item
          klass.new(item, config)
        end

        if collection_json.error
          errors << collection_json.error.message
        end
      else
        errors << data.status.to_s
      end

      handle_error(errors)
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

    def links
      @links ||= LinksProxy.new(collection_json.links, config)
    end

    def queries
      @queries ||= QueriesProxy.new(collection_json.queries, config)
    end

    def template
      @template ||= TemplateProxy.new(collection_json.template, config, href)
    end

    def error
      errors
    end

    def error?
      errors.count > 0
    end

    private

    attr_accessor :collection_json, :config, :items, :url
    attr_writer :errors

    def get(url, query_parameters = {})
      RequestBuilder.new(config, url).connection.get do |conn|
        query_parameters.each do |key, value|
          conn.params[key] = value
        end
      end
    end

    def this_href
      collection_json.links.find { |l| l.rel == "self" }.href
    end

    def handle_error(errors)
      if errors.include?("401")
        raise HttpError, "401 Unauthorized for #{url}"
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
