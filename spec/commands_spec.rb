require "spec_helper"

describe TeamSnap::CommandsProxy do
  use_vcr_cassette "team", :match_requests_on => [:host, :path, :body]

  let(:commands_proxy) { TeamSnap::Collection.new(
    "http://localhost:3003/teams/1", {}, TeamSnap::Config.new
  ).commands }

  describe "#new" do
    it "accepts an array of commands from a collection+json response and a config" do
      expect(commands_proxy).to be_a(TeamSnap::CommandsProxy)
    end
  end

  describe "#rels" do
    it "returns an array of the different commands available for the collection" do
      expect(commands_proxy.rels).to eq([:invite])
    end
  end

  describe "executing a command" do
    it "with valid data, it posts to the invite href when a match is found" do
      expect(
        commands_proxy.invite(
          :team_id => 1, :member_id => 8, :notify_as_member_id => 1
        ).status
      ).to eq(202)
    end

    it "with invalid data, it returns a 400" do
      expect(commands_proxy.invite.status).to eq(400)
    end
  end
end
