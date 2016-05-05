require "spec_helper"
require "teamsnap"

RSpec.describe "teamsnap__api", :vcr => true do
  context ".parse_error" do
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
        :body => Oj.dump("collection" => { :error => { :message => "Error Message"}})
      )
      expect(TeamSnap::Api.parse_error(response)).to eq("Error Message")
    end
  end
end
