require "spec_helper"
require "teamsnap"

RSpec.describe "structure", :vcr => true do

  describe ".create_collection_class" do
    let(:client) {
      client = TeamSnap::Client.new({
        :url => ROOT_TEST_URL,
        :client_id => "classic",
        :client_secret => "dont_tell_the_cops"
      })
    }
    let(:resp) { TeamSnap.run(client, :get, "/teams", {}) }

    it "registers new classes via introspection of the root collection" do
      TeamSnap::Structure.send(
        :create_collection_class,
        "teams",
        "http://localhost:3000/teams",
        resp,
        nil
      )
      expect { TeamSnap::Team }.to_not raise_error
    end

    it "sets the href attribute on the new class" do
      TeamSnap::Structure.send(
        :create_collection_class,
        "teams",
        "http://localhost:3000/teams",
        resp,
        nil
      )

      expect(TeamSnap::Team.href).to eq("#{ROOT_TEST_URL}/teams")
    end
  end

  describe ".init" do
    before(:all) do
      VCR.use_cassette("apiv3-init") do
        TeamSnap.init(
          :url => ROOT_TEST_URL,
          :client_id => "classic",
          :client_secret => "dont_tell_the_cops"
        )
      end
    end

    it "has all classes in schema loaded except for exceptions list endpoints" do
      collection = TeamSnap.run(TeamSnap.root_client, :get, "/", {})
      links = collection.fetch(:links) { [] }
        .select{|l| !TeamSnap::EXCLUDED_RELS.include?(l[:rel]) }

      links.each do |obj|
        expect {
          Object.const_get("TeamSnap::" + Inflecto.classify(obj[:rel]))
        }.to_not raise_error
      end
    end
  end  
end