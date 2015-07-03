module TeamSnap
  class Client
    attr_reader :configuration

    # Initializes a new Client object
    def initialize(options = {})
      configuration = TeamSnap::Configuration.new(options)
      yield(configuration) if block_given?
    end

    def method_missing(method, *args, &block)
      #synchronize
      #TeamSnap.init
    end

    def respond_to?(method, include_all=false)
    end

    private

    attr_writer :configuration
  end
end
