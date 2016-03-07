module TeamSnap
  class Structure

    class << self
      def init(client, collection)
        classes = []

        schema = collection
          .fetch(:links) { [] }
          .find { |link| link[:rel] == "schemas" } || {}

        if schema[:href]
          resp = client.get(schema[:href])
          classes = setup_model_classes(collection, resp)
        else
          client.in_parallel do
            classes = collection
              .fetch(:links) { [] }
              .map { |link| classify_rel(client, link) }
          end
        end
        classes.compact
        classes.each{ |cls| cls.parse_collection }
        true
      end

      private

      def setup_model_classes(collection, response)
        href_to_rel = collection
          .fetch(:links) { [] }
          .reject { |link| EXCLUDED_RELS.include?(link[:rel]) }
          .map { |link| [link[:href], link[:rel]]}

        href_to_rel = Hash[*href_to_rel.flatten]

        Oj.load(response.body)
          .map { |collection|
            col = collection.fetch(:collection) { {} }
            if rel = href_to_rel[col[:href]]
              create_collection_class(rel, col[:href], nil, col)
            end
          }
          .compact
      end

      def classify_rel(client, link)
        return if EXCLUDED_RELS.include?(link.fetch(:rel))

        rel = link.fetch(:rel)
        href = link.fetch(:href)
        resp = client.get(href)

        create_collection_class(rel, href, resp, nil)
      end

      def collection_module(href, resp, parsed_collection)
        Module.new do
          define_singleton_method(:included) do |descendant|
            descendant.send(:include, TeamSnap::Item)
            descendant.extend(TeamSnap::Collection)
            descendant.instance_variable_set(:@href, href)
            descendant.instance_variable_set(:@resp, resp)
            descendant.instance_variable_set(:@parsed_collection, parsed_collection)
          end
        end
      end

      def create_collection_class(rel, href, resp, collection)
        name = Inflecto.classify(rel)
        rel_module = collection_module(href, resp, collection)

        TeamSnap.const_set(
          name, Class.new { include rel_module }
        ) unless TeamSnap.const_defined?(name, false)
      end

    end
  end
end