module TeamSnap
  class Api

    def self.run(client, via, href, args = {}, template_args = false)
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

    def self.parse_error(resp)
      begin
        Oj.load(resp.body)
          .fetch(:collection)
          .fetch(:error)
          .fetch(:message)
      rescue KeyError
        resp.body
      end
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