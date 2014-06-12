module TeamsnapRb
  class LinksProxy
    include Enumerable

    def initialize(links, config)
      self.config = config
      self.links = links.inject({}) do |h, link|
        h.tap do |hash|
          hash[link.rel.to_sym] = Link.new(link, config)
        end
      end
    end

    def method_missing(method, *args)
      if link = links[method.to_sym]
        link.follow
      else
        super
      end
    end

    def respond_to?(method)
      links.include?(method.to_sym) || super
    end

    def each
      links.values.each do |link|
        yield link
      end
    end

    def rels
      links.keys
    end

    private

    attr_accessor :links, :config
  end
end
