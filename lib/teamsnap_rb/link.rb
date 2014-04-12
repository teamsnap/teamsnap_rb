module TeamsnapRb
  class Link
    def initialize(link, auth)
      self.auth = auth
      self.link = link
    end

    def follow
      @collection ||= Collection.new(href, {}, auth)
    end

    def rel
      link.rel
    end

    def href
      link.href
    end

    private

    attr_accessor :auth, :link
  end
end
