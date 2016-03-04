require "spec_helper"
require "teamsnap"

RSpec.describe "client", :vcr => true do
  let(:client_id) { "classic" }
  let(:client_secret) { "dont_tell_the_cops" }

  describe ".set_faraday_client" do
    it "sets up a new Faraday connection to the api" do
      expect(Faraday).to receive("new").with(any_args).and_call_original
      TeamSnap::Client.set_faraday_client(
        "localhost:3000",
        nil,
        "classic",
        "dont_tell_the_cops"
      )
    end
  end

  describe ".initialize" do
    it "sets the instance attribute 'faraday_client'" do
      TeamSnap.stub(:url).and_return(ROOT_TEST_URL)
      client = TeamSnap::Client.new({}, client_id, client_secret)
      expect(client.faraday_client).to_not be_nil
      expect(client.faraday_client.class).to eq(Faraday::Connection)
    end
  end

  describe "#api" do
  end
end