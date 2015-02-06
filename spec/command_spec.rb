require "spec_helper"

describe TeamSnap::Command do
  use_vcr_cassette "team", :match_requests_on => [:host, :path, :body], :record => :new_episodes

  let(:client) { TeamSnap::Client.new("http://localhost:3003/teams/1") }
  let(:command) { client.commands.first }

  describe "#new" do
    it "is built from a TeamSnap::Collection" do
      expect{command}.to_not raise_exception
    end
  end

  describe "#execute" do
    it "returns a Faraday::Response" do
      expect(
        command.execute(
          [:team_id => 1, :member_id => 8, :notify_as_member_id => 1]
        )
      ).to be_a(Faraday::Response)
    end

    it "returns an appropriate status code" do
      expect(
        command.execute(
          [:team_id => 1, :member_id => 8, :notify_as_member_id => 1]
        ).status
      ).to eq(202)
    end
  end

  describe "#href" do
    it "returns the href for the command" do
      expect(command.href).to eq("http://localhost:3003/teams/invite")
    end
  end

  describe "#rel" do
    it "returns the name of the command" do
      expect(command.rel).to eq("invite")
    end
  end

  describe "#prompt" do
    it "returns the prompt for the command" do
      expect(command.prompt).to eq("invite team members or contacts to join TeamSnap.")
    end
  end

  describe "#data" do
    it "returns the data for the command" do
      expect(command.data).to include("team_id", "member_id")
    end

    it "returns the data for the command" do
      expect(command.data).to be_a(Array)
    end
  end
end
