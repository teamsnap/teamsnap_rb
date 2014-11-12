module TeamsnapRb
  class Command
    def initialize(command, config)
      self.command = command
      self.config = config
    end

    def execute(attrs = {})
      post(attrs.flatten.first)
    end

    def rel
      command.rel
    end

    def href
      command.href
    end

    def prompt
      command.prompt
    end

    def data
      command.data.map(&:name)
    end

    private

    def post(attrs = {})
      RequestBuilder.new(config, href).connection.post do |conn|
        conn.body = attrs.to_json
        conn.headers['Content-Type'] = 'application/json'
      end
    end

    attr_accessor :command, :config
  end
end
