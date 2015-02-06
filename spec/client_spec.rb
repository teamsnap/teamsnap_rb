require "spec_helper"

describe TeamSnap::Client do
  describe "#new (GET production root/)" do
    use_vcr_cassette "production_root"

    it "raises an HttpError for unauthorized access" do
      expect{TeamSnap::Client.new}.to raise_exception(TeamSnap::HttpError)
    end
  end

  context "#new (GET local root/)" do
    use_vcr_cassette "root"

    it "does not raise an error when authorized" do
      expect{TeamSnap::Client.new("http://localhost:3003/")}.to_not raise_exception
    end

    it "return a TeamSnap::Collection" do
      expect(TeamSnap::Client.new("http://localhost:3003/")).to be_a(TeamSnap::Collection)
    end
  end

  context "#teams (GET local teams/)" do
    use_vcr_cassette "root"
    let(:client) { TeamSnap::Client.new("http://localhost:3003") }

    describe "client navigation of the api" do
      it "responds to links in the root collection, returning the appropriate collection" do
        expect(client.teams).to be_a(TeamSnap::Collection)
      end

      it "enables access to collections and items directly from the client" do
        team = client.teams.search(:id => 1).first
        expect(team.id).to eq(1)
      end
    end
  end
end
