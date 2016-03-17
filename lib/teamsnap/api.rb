module TeamSnap
  class Api

    CRUD_METHODS = [:find, :create, :update, :delete]
    CRUD_VIAS    = [:get,  :post,   :patch,  :delete]

    def self.run(client, method, klass, args = {}, template_args = false)
      klass = klass.class == Symbol ? get_class(klass) : klass
      via = via(klass, method)
      href = href(klass.href, method, args)
      args = args(method, args)
      client_send_args = template_args ? template_attributes(args) : args
      resp = TeamSnap.client_send(client, via, href, client_send_args)
      TeamSnap::Response.new(
        :args => args,
        :client => client,
        :client_send_args => client_send_args,
        :href => href,
        :resp => resp,
        :status => resp.status,
        :via => via
      )
    end

    def self.args(method, sent_args)
      case method
      when :update
        sent_args.except(:id)
      when :find, :delete
        {}
      else
        sent_args
      end
    end

    def self.get_class(sym)
      "TeamSnap::#{sym.to_s.singularize.camelcase}".constantize
    end

    def self.href(base_href, method, args = {})
      case method
      when :find, :delete
        if [Fixnum, String].include?(args.class)
          base_href + "/#{args}"
        elsif args.class == Hash
          base_href + "/#{args.fetch(:id)}"
        else
          raise TeamSnap::Error.new("You must pass in the `id` of the object you would like to :find or :delete")
        end
      when :create
        base_href
      when :update
        base_href + "/#{args.fetch(:id)}"
      else
        base_href + "/#{method}"
      end
    end

    def self.via(klass, method)
      queries = klass.query_names
      commands = klass.command_names

      method_map = CRUD_METHODS + queries + commands
      via_map = CRUD_VIAS + ([:get] * queries.count) + ([:post] * commands.count)

      # SET VIA
      if method_index = method_map.index(method)
        return via_map[method_index]
      else
        raise TeamSnap::Error.new("Method Missing: `#{method}` for Collection Class: `#{klass}`")
      end
    end

    def self.parse_error(resp)
      return "Object Not Found (404)" if resp.status == 404
      begin
        Oj.load(resp.body)
          .fetch(:collection)
          .fetch(:error)
          .fetch(:message)
      rescue KeyError
        resp.body
      end
    end

    def self.template_args?(method)
      [:create, :update].include?(method)
    end

    def self.template_attributes(attributes)
      request_attributes = {
        :template => {
          :data => []
        }
      }
      attributes.each do |key, value|
        request_attributes[:template][:data] << {
          "name" => key,
          "value" => value
        }
      end
      return request_attributes
    end

    def self.untemplate_attributes(request_attributes)
      attributes = {}
      request_attributes.fetch(:template).fetch(:data).each do |datum|
        attributes[datum.fetch(:name).to_sym] = datum.fetch(:value)
      end
      return attributes
    end
  end
end
