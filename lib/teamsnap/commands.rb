module TeamSnap
  class CommandsProxy
    include Enumerable

    def initialize(commands, config)
      self.config = config
      self.commands = commands.inject({}) do |h, command|
        h.tap do |hash|
          hash[command.rel.to_sym] = Command.new(command, config)
        end
      end
    end

    def method_missing(method, *args)
      if command = commands[method.to_sym]
        command.execute(args)
      else
        super
      end
    end

    def respond_to?(method)
      commands.include?(method.to_sym) || super
    end

    def each
      commands.values.each do |command|
        yield command
      end
    end

    def rels
      commands.keys
    end

    private

    attr_accessor :commands, :config
  end
end
