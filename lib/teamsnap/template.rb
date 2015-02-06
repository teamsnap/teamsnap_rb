module TeamSnap
  class Template
    def initialize(template, config, url)
      self.config = config
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

    attr_accessor :template, :config, :url

    def post(url, query_parameters = {})
      RequestBuilder.new(config, url).connection.post do |conn|
        conn.body = @data.to_json
        conn.headers['Content-Type'] = 'application/json'
      end
    end
  end
end
