require "spec_helper"

describe TeamsnapRb::Collection do
  describe "default attributes" do
    it "includes Enumerable" do
      expect(TeamsnapRb::Collection).to include(Enumerable)
    end
  end

  context "GET root", :vcr, record: :once do
    use_vcr_cassette "root"
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

    describe "size" do
      it "returns zero when there are no items" do
        expect(root_collection.size).to eq(0)
      end
    end

    describe "present?" do
      it "returns false when there are no iteams" do
        expect(root_collection.present?).to eq(false)
      end
    end

    describe "blank?" do
      it "returns true when there are no iteams" do
        expect(root_collection.blank?).to eq(true)
      end
    end
  end

  context "GET /teams/1", :vcr, record: :once do
    use_vcr_cassette "team"
    let(:team_collection) { TeamsnapRb::Collection.new("http://localhost:3003/teams/1", {}, TeamsnapRb::Config.new) }

    describe "#href" do
      it "responds to href with the correct value" do
        expect(team_collection.href).to eq("http://localhost:3003/teams")
      end
    end

    describe "#links" do
      it "returns a LinksProxy object" do
        expect(team_collection.links).to be_a(TeamsnapRb::LinksProxy)
      end
    end

    describe "#[]" do
      it "returns an Item when the collection has data elements" do
        expect(team_collection[0]).to be_a(TeamsnapRb::Item)
      end
    end

    describe "#queries" do
      it "returns a QueriesProxy object" do
        expect(team_collection.queries).to be_a(TeamsnapRb::QueriesProxy)
      end

      it "contains a set of Query objects" do
        expect(team_collection.queries.first).to be_a(TeamsnapRb::Query)
      end
    end

    describe "#each" do
      it "returns an array of items" do
        expect(team_collection.each {|item|}).to_not be_empty
      end
    end

    describe "size" do
      it "returns zero when there are no items" do
        expect(team_collection.size).to eq(1)
      end
    end

    describe "present?" do
      it "returns true when there are no iteams" do
        expect(team_collection.present?).to eq(true)
      end
    end

    describe "blank?" do
      it "returns false when there are no iteams" do
        expect(team_collection.blank?).to eq(false)
      end
    end

    describe "#where" do
      it "returns a CollectionWhereProxy" do
        expect(team_collection.where({})).to be_a(TeamsnapRb::Collection::CollectionWhereProxy)
      end

      it "returns nil when trying to access a type that doesn't exist in the collection" do
        expect(team_collection.where({type: "division"})[0]).to be_nil
      end

      it "returns an array of items that match the type passed in" do
        expect(team_collection.where({type: "team"})[0]).to be_a(TeamsnapRb::Item)
      end

      it "the item selected has the expected data" do
        expect(team_collection.where({type: "team"})[0].name).to eq("Test Mania")
      end
    end

    describe "#error" do
      it "returns an empty array if there are no errors" do
        expect(team_collection.error).to be_empty
      end
    end

    describe "#error?" do
      it "returns false if there are no errors" do
        expect(team_collection.error?).to eq(false)
      end
    end
  end
end
