require "spec_helper"
require "teamsnap"

RSpec.describe "teamsnap__api", :vcr => true do
  describe ".run" do
    before(:all) do
      VCR.use_cassette("apiv3-init") do
        TeamSnap.init(
          :url => ROOT_TEST_URL,
          :client_id => "classic_service",
          :client_secret => "dont_tell_the_cops"
        )
      end
    end

    context "when method is delete" do
      it "can handle empty response" do
        expect {
          TeamSnap::Api.run(
            TeamSnap.root_client,
            :delete,
            TeamSnap::Event,
            1
          )
        }.to_not raise_error(JSON::ParserError)
      end
    end
  end

  describe ".parse_error" do
    it "returns error message on a 403 and an empty body" do
      response = Faraday::Response.new(
        :status => 403,
        :body => ""
      )
      expect(TeamSnap::Api.parse_error(response)).to eq("Forbidden (403)")
    end

    it "returns error message on a 404" do
      response = Faraday::Response.new(
        :status => 404,
        :body => ""
      )
      expect(TeamSnap::Api.parse_error(response)).to eq("Object Not Found (404)")
    end

    it "returns a proper error message" do
      response = Faraday::Response.new(
        :status => 403,
        :body => JSON.generate("collection" => { :error => { :message => "Error Message"}})
      )
      expect(TeamSnap::Api.parse_error(response)).to eq("Error Message")
    end
  end
end
