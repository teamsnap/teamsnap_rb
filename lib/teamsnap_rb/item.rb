module TeamsnapRb
  class Item
    class << self
      attr_accessor :templates
    end
    @templates = {}

    def initialize(item, config)
      self.config = config
      self.item = item
    end

    def href
      item.href
    end

    def data
      item.data
    end

    def template
      self.class.templates[type] ||= fetch_template
    end

    def this
      @this ||= Collection.new(href, {}, config)
    end

    def links
      @links ||= LinksProxy.new(item.links, config)
    end

    def commands
      @commands ||= CommandsProxy.new(this.commands, config)
    end

    def delete
      response = delete_href(href)
      if response.status == 204
        true
      else
        raise FailedToDelete
      end
    end

    def with(attrs)
      attrs = Hash[attrs.map{ |k, v| [k.to_s, v] }]
      dirtied_attrs = attrs.keys
      attrs = attributes.merge(attrs)

      new_data = attrs.inject([]) do |arr, (key, value)|
        arr << Conglomerate::Datum.new(:name => key, :value => value)
      end

      item = Conglomerate::Item.new(
        :href => href,
        :data => new_data
      )

      Item.new(item, config).tap do |it|
        it.send(:dirty, dirtied_attrs)
      end
    end

    def save
      attrs_to_update = dirty_attributes.inject({}) do |h, attr|
        h.tap do |hash|
          hash[attr] = attributes[attr]
        end
      end

      request = RequestBuilder.new(config, href).connection.patch do |conn|
        conn.body = template.build(attrs_to_update).to_json
        conn.headers["Content-Type"] = "application/json"
      end

      Collection.new(nil, nil, config, :request => request)
    end

    def method_missing(method, *args)
      if datum = data.find { |d| d.name == method.to_s }
        unless instance_variable_get("@#{method}_datum")
          instance_variable_set("@#{method}_datum", datum.value)
        end

        instance_variable_get("@#{method}_datum")
      elsif links.respond_to?(method)
        links.send(method)
      elsif commands.respond_to?(method)
        commands.send(method, args)
      else
        super
      end
    end

    def respond_to?(method)
      if data.find { |d| d.name == method.to_s }
        true
      elsif
        links.respond_to?(method)
      elsif
        commands.respond_to?(method)
      end
    end

    private

    def attributes
      @attributes ||= data.inject({}) do |h, datum|
        h.tap do |hash|
          hash[datum.name] = datum.value
        end
      end
    end

    def delete_href(href)
      RequestBuilder.new(config, href).connection.delete
    end

    def dirty(attrs)
      self.dirty_attributes = attrs
    end

    def fetch_template
      this.template
    end

    def fetch_commands
      this.commands
    end

    attr_accessor :item, :config, :dirty_attributes
  end

  class FailedToDelete < StandardError;end;
end
