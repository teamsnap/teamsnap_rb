module TeamsnapRb
  class Link
    def initialize(link)
      self.link = link
    end

    def follow
      @collection ||= Collection.new(href, {})
    end

    def rel
      link.rel
    end

    def href
      link.href
    end

    private

    attr_accessor :link
  end
end
