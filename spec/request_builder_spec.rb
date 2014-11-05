require "spec_helper"

module TeamsnapRb
  describe RequestBuilder do
    describe "#new" do
      it "returns a RequestBuilder" do
        expect(RequestBuilder.new("http://url.com")).to be_a(RequestBuilder)
      end

      it "sets the correct host" do
        request_builder = RequestBuilder.new("http://url.com")
        expect(
          request_builder.connection.url_prefix.host
        ).to eql("url.com")
      end
    end
  end
end
