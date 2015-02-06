require "spec_helper"

describe TeamSnap::LinksProxy do
  use_vcr_cassette "root"
  let(:links_proxy) { TeamSnap::Collection.new(
    "http://localhost:3003", {}, TeamSnap::Config.new
  ).links }

  describe "#new" do
    it "accepts an array of links from a collection+json response and a config" do
      expect(links_proxy).to be_a(TeamSnap::LinksProxy)
    end
  end

  describe "#rels" do
    it "returns an array of the link names represented as symbols" do
      expect(links_proxy.rels).to include(:teams, :members)
    end
  end

  describe "sending a link name to the LinksProxy" do
    use_vcr_cassette "teams"

    it "follows the link if a matching link rel is found" do
      expect(links_proxy.teams).to be_a(TeamSnap::Collection)
    end

    it "returns a TeamSnap::Collection of the matching rel as the link" do
      expect(links_proxy.teams.href).to include("/teams")
    end
  end
end
