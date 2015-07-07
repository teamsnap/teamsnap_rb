require "oj"

module TeamSnap
  class Request
    attr_accessor :connection
    attr_accessor :via
    attr_accessor :href
    attr_accessor :args

    def initialize(connection, via, href, args)
      @connection = connection
      @request_method = request_method
      @href = href
      @args = args
    end

    def execute
      case request_method
      when :get
        @connection.send(@request_method, @href, @args)
      when :post
        @connection.send(@request_method, @href) do |req|
          req.body = Oj.dump(@args)
        end
      else
        raise TeamSnap::Error.new("Don't know how to run `#{@request_method}`")
      end
    end
  end
end
