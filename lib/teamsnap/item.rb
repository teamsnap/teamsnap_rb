module TeamSnap
  module Item

    class << self
      def load_items(client, collection)
        collection
          .fetch(:items) { [] }
          .map { |item|
            data = parse_data(item)
              .merge(:href => item[:href])
              .merge(url_attributes(item))
            type = type_of(item)
            cls = load_class(type, data)

            cls.new(data).tap { |obj|
              obj.send(:load_links, client, item.fetch(:links) { [] })
            }
          }
      end

      def parse_data(item)
        data = item
          .fetch(:data)
          .map { |datum|
            name = datum.fetch(:name)
            value = datum.fetch(:value)
            type = datum.fetch(:type) { :default }

            value = DateTime.parse(value) if value && type == "DateTime"

            [name, value]
          }
        hashify(data)
      end

      def type_of(item)
        item
          .fetch(:data)
          .find { |datum| datum.fetch(:name) == "type" }
          .fetch(:value)
      end

      def load_class(type, data)
        TeamSnap.const_get(Inflecto.camelize(type), false).tap { |cls|
          if cls.include?(ShallowAttributes)
            cls.class_eval do
              # require 'pry'
              # binding.pry
              # attributes = cls.attribute_set.map(&:name)
              # data
              #   .select { |name, _| !attributes.include?(name.to_sym) }
              #   .each { |name, value| attribute name, value.class }
            end
          else
            cls.class_eval do
              include ShallowAttributes

              attribute :href, String
              values do
                data.each { |name, value| attribute name, value.class }
              end
            end
          end
        }
      end

      def url_attributes(item)
        links = item
          .fetch(:links) { [] }
          .map { |link| ["#{link.fetch(:rel)}_url", link.fetch(:href)] }
        hashify(links)
      end

      def hashify(arr)
        arr.inject({}) { |hash, (key, value)| hash[key] = value; hash }
      end
    end

    private

    def load_links(client, links)
      links.each do |link|
        next if EXCLUDED_RELS.include?(link.fetch(:rel))

        rel = link.fetch(:rel)
        href = link.fetch(:href)
        is_singular = rel == Inflecto.singularize(rel)

        define_singleton_method(rel) {
          instance_variable_get("@#{rel}") || instance_variable_set(
            "@#{rel}", -> {
              coll = TeamSnap::Item.load_items(
                client,
                TeamSnap.run(client, :get, href)
              )
              is_singular ? coll.first : coll
            }.call
          )
        }
      end

      define_singleton_method(:update) { |attributes|
        patch_attributes = TeamSnap::Api.template_attributes(attributes)

        response = TeamSnap.run(client, :patch, instance_variable_get("@href"), patch_attributes)
        TeamSnap::Item.load_items(client, response).first
      }

      define_singleton_method(:delete) {
        response = TeamSnap.run(client, :delete, instance_variable_get("@href"), {})
        TeamSnap::Item.load_items(client, response).first
      }
    end
  end
end
