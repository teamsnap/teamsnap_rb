module TeamSnap
  class Response

    def self.load_collection(resp, via)
      if resp.success?
        return Oj.load(resp.body).fetch(:collection)
      else
        if resp.headers["content-type"].match("json")
          if resp.status == 404
            raise TeamSnap::NotFound.new("Object not found.")
          else
            raise TeamSnap::Error.new(
              TeamSnap::Api.parse_error(resp)
            )
          end
        else
          raise TeamSnap::Error.new(
            "`#{via}` call was unsuccessful. " +
            "Unexpected response content-type. " +
            "Check TeamSnap APIv3 connection")
        end
      end
    end

    def self.process(client, resp, via, href, args)
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
      body = Oj.load(@resp.body)
      @collection = body.fetch(:collection) { {} }
      @message = "Data retrieved successfully"
      @objects = TeamSnap::Item.load_items(@client, @collection)
    end

    def process_action
      body = Oj.load(@resp.body)
      @collection = body.fetch(:collection) { {} }
      @message = "`#{@via}` call was successful"
      @objects = TeamSnap::Item.load_items(@client, @collection)
    end

    def process_error
      @collection = {}
      @message = TeamSnap::Api.parse_error(@resp)
      @objects = TeamSnap::Item.load_items(@client, @collection)
    end

    def success?
      @status / 100 == 2
    end

    def errors?
      @status / 100 != 2
    end

  end
end