module TeamSnap
  module Collection

    class << self

      def apply_endpoints(obj, collection)
        queries = collection.fetch(:queries) { [] }
        commands = collection.fetch(:commands) { [] }

        endpoint_creation_set(obj, queries, :get)
        endpoint_creation_set(obj, commands, :post)
      end

      def endpoint_creation_set(obj, creation_set, via)
        creation_set.each{ |endpoint| register_endpoint(obj, endpoint, :via => via) }
      end

      def register_endpoint(obj, endpoint, opts)
        rel = endpoint.fetch(:rel)
        href = endpoint.fetch(:href)
        valid_args = endpoint.fetch(:data) { [] }
          .map { |datum| datum.fetch(:name).to_sym }
        via = opts.fetch(:via)

        obj.define_singleton_method(rel) do |client, *args|
          args = Hash[*args]

          unless (args.keys & valid_args).any?
            raise ArgumentError.new(
              "Invalid argument(s). Valid argument(s) are #{valid_args.inspect}"
            )
          end

          resp = TeamSnap.run(client, via, href, args)
          TeamSnap::Item.load_items(client, resp)
        end
      end
    end

    def actions
      actions = parsed_collection.fetch(:actions) {
        %w(create read update delete search)
      }
      return actions.map(&:to_sym)
    end

    def queries
      parsed_collection.fetch(:queries) { [] }
    end

    def query_names
      queries.map{ |q| q[:rel].to_sym }
    end

    def commands
      parsed_collection.fetch(:commands) { [] }
    end

    def command_names
      commands.map{ |q| q[:rel].to_sym }
    end

    def create(client, attributes = {})
      post_attributes = TeamSnap::Api.template_attributes(attributes)

      create_resp = TeamSnap.run(client, :post, href, post_attributes)
      TeamSnap::Item.load_items(client, create_resp).first
    end

    def update(client, id, attributes = {})
      patch_attributes = TeamSnap::Api.template_attributes(attributes)

      update_resp = TeamSnap.run(client, :patch, href+"/#{id}", patch_attributes)
      TeamSnap::Item.load_items(client, update_resp).first
    end

    def delete(client, id)
      TeamSnap.run(client, :delete, href+"/#{id}", {})
    end

    def template_attributes
      template = parsed_collection.fetch(:template) {}
      data = template.fetch(:data) { [] }
      data
        .reject{ |col| col.fetch(:name) == "type" }
        .map{ |col| col.fetch(:name) }
    end

    def href
      self.instance_variable_get(:@href)
    end

    def resp
      self.instance_variable_get(:@resp)
    end

    def parsed_collection
      self.instance_variable_get(:@parsed_collection)
    end

    def parse_collection
      if resp
        TeamSnap.response_check(resp, :get)
        collection = Oj.load(resp.body).fetch(:collection) { [] }
      elsif parsed_collection
        collection = parsed_collection
      end

      TeamSnap::Collection.apply_endpoints(self, collection)
      enable_find if respond_to?(:search)
    end

    private

    def enable_find
      define_singleton_method(:find) do |client, id|
        search(client, :id => id).first.tap do |object|
          raise TeamSnap::NotFound.new(
            "Could not find a #{self} with an id of '#{id}'."
          ) unless object
        end
      end
    end
  end
end
