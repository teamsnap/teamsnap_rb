module TeamsnapRb
  class TemplateProxy
    def initialize(template, auth, url)
      self.auth = auth
      self.template = template
      self.url = url
    end

    def build(attrs={})
      @data = template.build(attrs)
    end

    def push(attrs={})
      build(attrs)
      publish
    end

    def data
      template.data
    end

    def publish
      post(url, @data) if @data
    end

    private

    attr_accessor :template, :auth, :url

    def post(url, query_parameters = {})
      RequestBuilder.new(auth, url).connection.post do |conn|
        conn.body = @data.to_json
        conn.headers['Content-Type'] = 'application/json'
      end
    end
  end
end
