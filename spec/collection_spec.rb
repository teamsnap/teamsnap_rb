require "spec_helper"

describe TeamsnapRb::Collection do
  use_vcr_cassette "root"

  describe "default attributes" do
    it "includes Enumerable" do
      expect(TeamsnapRb::Collection).to include(Enumerable)
    end
  end

  context "GET root", :vcr, record: :once do
    let(:root_collection) { TeamsnapRb::Collection.new("http://localhost:3003", {}, TeamsnapRb::Config.new) }

    describe "#href" do
      it "responds to href with the correct value" do
        expect(root_collection.href).to eq("http://localhost:3003/")
      end
    end

    describe "#links" do
      it "returns a LinksProxy object" do
        expect(root_collection.links).to be_a(TeamsnapRb::LinksProxy)
      end
    end

    describe "#[]" do
      it "returns nil when the collection does not have any data elements" do
        expect(root_collection[0]).to be_nil
      end
    end

    describe "#queries" do
      it "returns a QueriesProxy object" do
        expect(root_collection.queries).to be_a(TeamsnapRb::QueriesProxy)
      end

      it "contains a set of Query objects" do
        expect(root_collection.queries.first).to be_a(TeamsnapRb::Query)
      end
    end

    describe "#each" do
      it "returns an empty array when there are not data elements" do
        expect(root_collection.each).to eq([])
      end
    end

    describe "#where" do
      it "returns a CollectionWhereProxy" do
        expect(root_collection.where({})).to be_a(TeamsnapRb::Collection::CollectionWhereProxy)
      end

      it "returns nil when trying to access an empty collection" do
        expect(root_collection.where({})[0]).to be_nil
      end
    end

    describe "#error" do
      it "returns an empty array if there are no errors" do
        expect(root_collection.error).to be_empty
      end
    end

    describe "#error?" do
      it "returns false if there are no errors" do
        expect(root_collection.error?).to eq(false)
      end
    end
  end
end
