require "spec_helper"
require "teamsnap"

RSpec.describe "teamsnap__client", :vcr => true do
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
      client = TeamSnap::Client.new({
        :url => ROOT_TEST_URL,
        :client_id => client_id,
        :client_secret => client_secret
      })
      expect(client.faraday_client).to_not be_nil
      expect(client.faraday_client.class).to eq(Faraday::Connection)
    end
  end

  context "when calling `via`'s on the client" do
    let(:client) {
      TeamSnap::Client.new({
        :url => ROOT_TEST_URL,
        :client_id => client_id,
        :client_secret => client_secret
      })
    }

    it "does not override any of the HTTP actions" do
      expect(client.respond_to?(:get)).to be(false)
    end

    it "does not raise an error when the HTTP actions are called" do
      expect {
        client.send(:get)
      }.to_not raise_error
    end

    it "passes them to the faraday_client using method_missing" do
      expect_any_instance_of(
        TeamSnap::Client
      ).to receive(:method_missing).with(any_args).and_call_original
      client.send(:get, "/", {})
    end
  end

  describe "#api" do
    before(:all) do
      VCR.use_cassette("apiv3-init") do
        TeamSnap.init(
          :url => ROOT_TEST_URL,
          :client_id => "classic",
          :client_secret => "dont_tell_the_cops"
        )
      end
    end

    it "Sends the proper information to TeamSnap::Api.run" do
      expect(TeamSnap::Api).to receive(:run).with(TeamSnap.root_client, :find, TeamSnap::Team, 1, false)
      TeamSnap.root_client.api(:find, TeamSnap::Team, 1)
    end
  end

  context "when specifying a header flag" do
    it "correctly sets the ghost header flag" do
      client = TeamSnap.init(
        :url => ROOT_TEST_URL,
        :client_id => client_id,
        :client_secret => client_secret,
        :header => {"X-Teamsnap-Api-Features" => "ghost_contact"}
      )

      headers = TeamSnap.root_client.headers
      expect(headers["X-Teamsnap-Api-Features"]).to eq("ghost_contact")
    end

    it "won't set feature headers without the header variable present" do
      client = TeamSnap.init(
        :url => ROOT_TEST_URL,
        :client_id => client_id,
        :client_secret => client_secret
      )

      headers = TeamSnap.root_client.headers
      expect(headers["X-Teamsnap-Api-Features"]).to eq(nil)
    end
  end
end
