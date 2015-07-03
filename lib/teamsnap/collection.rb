module TeamSnap
  module Collection
    def href
      self.instance_variable_get(:@href)
    end

    def resp
      self.instance_variable_get(:@resp)
    end

    def parse_collection(connection)
      if resp.status == 200
        collection = Oj.load(resp.body)
          .fetch(:collection)

        TeamSnap.apply_endpoints(self, collection, connection)
        enable_find if respond_to?(:search)
      else
        error_message = TeamSnap.parse_error(resp)
        raise TeamSnap::Error.new(error_message)
      end
    end

    private

    def enable_find
      define_singleton_method(:find) do |id|
        search(:id => id).first.tap do |object|
          raise TeamSnap::NotFound.new(
            "Could not find a #{self} with an id of '#{id}'."
            ) unless object
          end
      end
    end
  end
end
