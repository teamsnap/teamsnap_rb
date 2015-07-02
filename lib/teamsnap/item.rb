module TeamSnap
  module Item
    private

    def load_links(links)
      links.each do |link|
        next if EXCLUDED_RELS.include?(link.fetch(:rel))

        rel = link.fetch(:rel)
        href = link.fetch(:href)
        is_singular = rel == Inflecto.singularize(rel)

        define_singleton_method(rel) {
          instance_variable_get("@#{rel}") || instance_variable_set(
            "@#{rel}", -> {
              coll = TeamSnap.load_items(
                TeamSnap.run(:get, href)
              )
              is_singular ? coll.first : coll
            }.call
          )
        }
      end
    end
  end
end
