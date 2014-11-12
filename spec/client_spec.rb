require "spec_helper"

describe TeamsnapRb::Client do
  describe "#new (GET production root/)" do
    use_vcr_cassette "production_root"

    it "raises an HttpError for unauthorized access" do
      expect{TeamsnapRb::Client.new}.to raise_exception(TeamsnapRb::HttpError)
    end
  end

  context "#new (GET local root/)" do
    use_vcr_cassette "root"

    it "does not raise an error when authorized" do
      expect{TeamsnapRb::Client.new("http://localhost:3003/")}.to_not raise_exception
    end

    it "return a TeamsnapRb::Collection" do
      expect(TeamsnapRb::Client.new("http://localhost:3003/")).to be_a(TeamsnapRb::Collection)
    end
  end

  context "#teams (GET local teams/)" do
    use_vcr_cassette "root"
    let(:client) { TeamsnapRb::Client.new("http://localhost:3003") }

    describe "client navigation of the api" do
      it "responds to links in the root collection, returning the appropriate collection" do
        expect(client.teams).to be_a(TeamsnapRb::Collection)
      end

      it "enables access to collections and items directly from the client" do
        team = client.teams.search(:id => 1).first
        expect(team.id).to eq(1)
      end
    end
  end
end
