require "spec_helper"

describe TeamsnapRb::Link do
  let(:config) { TeamsnapRb::Config.new }
  let(:collection) { double(
    TeamsnapRb::Collection, :href => "http://localhost:3003/")
  }
  let(:conglomerate_link) { double(
    Conglomerate::Link, :rel => "team",
    :href => "http://localhost:3003/", :follow => collection
  ) }
  let(:link) { TeamsnapRb::Link.new(conglomerate_link, config) }

  describe "#new" do
    it "accepts a Conglomerate item as a link" do
      expect{link}.to_not raise_exception
    end
  end

  describe "#follow" do
    use_vcr_cassette "root"

    it "returns the Collection represented by that href" do
      expect(link.follow).to be_a(TeamsnapRb::Collection)
    end

    it "returns the Collection represented by that href" do
      expect(link.follow.href).to eq("http://localhost:3003/")
    end
  end

  describe "#rel" do
    it "returns the rel of the link passed in" do
      expect(link.rel).to eq("team")
    end
  end

  describe "#href" do
    it "returns the href of the link passed in" do
      expect(link.href).to eq("http://localhost:3003/")
    end
  end
end
