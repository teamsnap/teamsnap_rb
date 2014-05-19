module TeamsnapRb
  class Item
    class << self
      attr_accessor :templates
    end
    @templates = {}

    def initialize(item, auth)
      self.auth = auth
      self.item = item
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

      Item.new(item, auth).tap do |it|
        it.send(:dirty, dirtied_attrs)
      end
    end

    def save
      attrs_to_update = dirty_attributes.inject({}) do |h, attr|
        h.tap do |hash|
          hash[attr] = attributes[attr]
        end
      end

      request = RequestBuilder.new(auth, href).connection.patch do |conn|
        conn.body = template.build(attrs_to_update).to_json
        conn.headers["Content-Type"] = "application/json"
      end

      Collection.new(nil, nil, auth, :request => request)
    end

    def attributes
      @attributes ||= data.inject({}) do |h, datum|
        h.tap do |hash|
          hash[datum.name] = datum.value
        end
      end
    end

    def href
      item.href
    end

    def method_missing(method, *args)
      if datum = item.data.find { |d| d.name == method.to_s }
        unless instance_variable_get("@#{method}_datum")
          instance_variable_set("@#{method}_datum", datum.value)
        end

        instance_variable_get("@#{method}_datum")
      elsif links.respond_to?(method)
        links.send(method)
      else
        super
      end
    end

    def respond_to?(method)
      if item.data.find { |d| d.name == method.to_s }
        true
      else
        links.respond_to?(method)
      end
    end

    def data
      item.data
    end

    def template
      self.class.templates[type] ||= fetch_template
    end

    def delete
      response = delete_href(href)
      if response.status == 204
        true
      else
        raise FailedToDelete
      end
    end

    def this
      @this ||= Collection.new(href, {}, auth)
    end

    def links
      @links ||= LinksProxy.new(item.links, auth)
    end

    private

    def delete_href(href)
      RequestBuilder.new(auth, href).connection.delete
    end

    def dirty(attrs)
      self.dirty_attributes = attrs
    end

    def fetch_template
      this.template
    end

    attr_accessor :item, :auth, :dirty_attributes
  end

  class FailedToDelete < StandardError;end;
end
