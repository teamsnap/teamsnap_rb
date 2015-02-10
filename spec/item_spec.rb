require "spec_helper"

vcr_options = {
  :cassette_name => "team",
  :allow_playback_repeats => true,
  :match_requests_on => [:host, :path, :body, :method]
}
describe TeamSnap::Item, :vcr => vcr_options do
  let(:team_collection) { TeamSnap::Collection.new("http://localhost:3003/teams/1", {}, TeamSnap::Config.new) }
  let(:team_item) { team_collection[0] }

  it "represents a single item and therefore does not include Enumerable" do
    expect(TeamSnap::Item).to_not include(Enumerable)
  end

  context "PATCH teams/1" do
    describe "#save" do
      it "successfully saves the item and returns it's collection" do
        expect(team_item.with(:name => "Danger Rangers").save).to be_a(TeamSnap::Collection)
      end

      it "includes the item in the returned collection" do
        expect(team_item.with(:name => "Danger Rangers").save.first.href).to eq(team_item.href)
      end

      it "includes the updated item's attributes in the returned collection" do
        expect(team_item.with(:name => "Danger Rangers").save.first.name).to eq("Danger Rangers")
      end
    end
  end

  context "DELETE teams/1" do
    describe "#delete" do
      it "successfully deletes the item and returns true" do
        expect(team_item.delete).to eq(true)
      end
    end
  end

  context "GET teams/1" do
    describe "#href" do
      it "returns 'teams/1' where 1 is the id of the item" do
        expect(team_item.href).to eq("http://localhost:3003/teams/1")
      end
    end

    describe "accessing item properties" do
      it "provides direct access to item properties" do
        expect(team_item.name).to eq("Test Mania")
      end
    end

    describe "#data" do
      let(:data) { team_item.data }

      it "returns a Conglomerate::Array of attributes from the collection response's data section" do
        expect(data).to be_a(Conglomerate::Array)
      end

      it "returns a Conglomerate::Datum for each data item in the Conglomerate::Array" do
        expect(data.first).to be_a(Conglomerate::Datum)
      end

      it "returns the correct value for a given datum" do
        expect(data.first.name).to eq("id")
        expect(data.first.value).to eq(1)
      end
    end

    describe "#commands" do
      it "returns a TeamSnap::CommandsProxy" do
        expect(team_item.commands).to be_a(TeamSnap::CommandsProxy)
      end

      it "returns a 400 when the command is executed without correct arguments" do
        expect(team_item.invite.status).to eq(400)
      end

      it "returns a 202 when the command is executed with correct arguments" do
        expect(
          team_item.invite(
            :team_id => 1, :member_id => 8, :notify_as_member_id => 1
          ).status
        ).to eq(202)
      end
    end

    describe "#template" do
      it "returns a TeamSnap::Template" do
        expect(team_item.template).to be_a(TeamSnap::Template)
      end

      it "caches the template on the Item class" do
        team_item.template
        expect(TeamSnap::Item.templates.keys).to include("team")
      end
    end

    describe "#this" do
      it "returns the collection this item belongs to" do
        expect(team_item.this).to be_a(TeamSnap::Collection)
      end

      it "returns a collection with an href that is the generalized form of the specific item href" do
        expect(team_item.href).to include(team_item.this.href)
      end
    end

    describe "#links" do
      it "returns a LinksProxy" do
        expect(team_item.links).to be_a(TeamSnap::LinksProxy)
      end

      it "consists of an array of Links" do
        expect(team_item.links.first).to be_a(TeamSnap::Link)
      end

      it "can be accessed like an array" do
        expect(team_item.links.first.href).to eq("http://localhost:3003/assignments/search?team_id=1")
      end
    end

    describe "#with(attrs)" do
      it "returns a new TeamSnap::Item" do
        expect(team_item.with(name: "Goofballs")).to be_a(TeamSnap::Item)
      end

      it "has the updated attributes on the new TeamSnap::Item" do
        expect(team_item.with(name: "Goofballs").name).to eq("Goofballs")
      end

      it "creates a new object rather than mutating the existing object" do
        expect{team_item.with(name: "Goofballs")}.to_not change(team_item, :name)
      end
    end
  end
end
