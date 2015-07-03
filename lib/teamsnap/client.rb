module TeamSnap
  class Client
    def initialize
      yield(configuration) if block_given?
    end

    def method_missing(method, *args, &block)
      #synchronize
      #TeamSnap.init
    end

    def respond_to?(method, include_all=false)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
