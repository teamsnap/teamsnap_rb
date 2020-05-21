module TeamSnap
  class Response

    class << self
      def load_collection(resp)
        if resp.success?
          return JSON.parse(resp.body, :symbolize_names => true).fetch(:collection)
        else
          content_type = resp.headers["content-type"]
          if content_type && content_type.match("json")
            if resp.status == 404
              raise TeamSnap::NotFound.new("Object not found.")
            else
              raise TeamSnap::Error.new(
                TeamSnap::Api.parse_error(resp)
              )
            end
          else
            raise TeamSnap::Error.new(
              "`#{resp.env.method}` call was unsuccessful. " +
              "Unexpected response content-type. " +
              "Check TeamSnap APIv3 connection")
          end
        end
      end

      def process(client, resp, via, href, args)
        response_object = self.new(
          :args => args,
          :client => client,
          :href => href,
          :resp => resp,
          :status => resp.status,
          :via => via
        )
        if resp.success?
          if via == :get
            response_object.process_info
          else
            response_object.process_action
          end
        else
          response_object.process_error
        end
      end
    end

    attr_accessor :args, :client, :collection, :href, :message,
                  :objects, :resp, :status, :via

    def initialize(opts = {})
      [
        :args, :client, :collection, :href, :message,
        :objects, :resp, :status, :via
      ].each do |attribute_name|
        instance_variable_set("@#{attribute_name}", opts.fetch(attribute_name, nil))
      end
      if resp
        if resp.success?
          if via == :get
            process_info
          else
            process_action
          end
        else
          process_error
        end
      end
    end

    def process_info
      raise @resp.body
      body = JSON.parse(@resp.body, :symbolize_names => true)
      @collection = body.fetch(:collection) { {} }
      @message = "Data retrieved successfully"
      @objects = TeamSnap::Item.load_items(@client, @collection)
    end

    def process_action
      body = JSON.parse(@resp.body, :symbolize_names => true) || {}
      @collection = body.fetch(:collection) { {} }
      @message = "`#{@via}` call was successful"
      @objects = TeamSnap::Item.load_items(@client, @collection)
    end

    def process_error
      if @resp.headers["content-type"].match("json")
        body = JSON.parse(@resp.body, :symbolize_names => true) || {}
        @collection = body.fetch(:collection) { {} }
        @message = TeamSnap::Api.parse_error(@resp)
        @objects = TeamSnap::Item.load_items(@client, @collection)
      else
        raise TeamSnap::Error.new(
          "`#{@via}` call with arguments #{@args} was unsuccessful. " +
            "The server returned a status of #{@status}."
        )
      end
    end

    def success?
      @status / 100 == 2
    end

    def errors?
      @status / 100 != 2
    end

  end
end
