module TeamsnapRb
  class Link
    def initialize(link, config)
      self.config = config
      self.link = link
    end

    def follow
      @collection ||= Collection.new(href, {}, config)
    end

    def rel
      link.rel
    end

    def href
      link.href
    end

    private

    attr_accessor :config, :link
  end
end
