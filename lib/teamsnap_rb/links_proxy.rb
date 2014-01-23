module TeamsnapRb
  class LinksProxy
    def initialize(links, auth)
      self.auth = auth
      self.links = links
    end

    def method_missing(method, *args)
      if link = links.find { |l| l.rel == method.to_s }
        unless instance_variable_get("@#{method}_collection")
          instance_variable_set("@#{method}_collection", CollectionBase.new(link.href, auth))
        end

        instance_variable_get("@#{method}_collection")
      else
        super
      end
    end

    def respond_to?(method)
      if links.find { |l| l.rel == method.to_s }
        true
      else
        false
      end
    end

    private

    attr_accessor :links, :auth
  end
end
