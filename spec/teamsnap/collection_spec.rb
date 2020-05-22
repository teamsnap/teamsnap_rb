require "spec_helper"
require "teamsnap"

RSpec.describe "teamsnap__collection", :vcr => true do
  before(:all) do
    VCR.use_cassette("apiv3-init") do
      TeamSnap.init(
        :url => ROOT_TEST_URL,
        :client_id => "classic_service",
        :client_secret => "dont_tell_the_cops"
      )
    end
  end

  it "handles fetching data via queries" do
    ts = TeamSnap::Team.search(TeamSnap.root_client, :id => 1)

    expect(ts).to_not be_empty
    expect(ts[0].id).to eq(1)
  end

  it "handles queries with no data" do
    ts = TeamSnap::Team.search(TeamSnap.root_client, :id => 0)

    expect(ts).to be_empty
  end

  it "raises an exception when a query is invalid" do
    expect {
      TeamSnap::Team.search(TeamSnap.root_client, :foo => :bar)
    }.to raise_error(
      ArgumentError,
      "Invalid argument(s). Valid argument(s) are [:id, :team_id, :user_id, :division_id, :page_size, :page_number, :sort_name]"
    )
  end

  it "handles executing an action via commands" do
    ms = TeamSnap::Member.disable_member(TeamSnap.root_client, :member_id => 1)

    expect(ms).to_not be_empty
    expect(ms[0].id).to eq(1)
  end

  it "handles executing an action via commands with multiple params" do
    user_client = TeamSnap::Client.new({:token => "6-classic-dont_tell_the_cops"})

    ms = TeamSnap::Team.invite(
      user_client,
      :team_id => 1, :member_id => [9, 11], :notify_as_member_id => 3,
      :introduction => "Welcome! This is our team\n ...the superstars!"
    )

    expect(ms.size).to eq(2)
    expect(ms.map(&:id)).to eq([9, 11])
    expect(ms.map(&:is_invited)).to eq([true, true])
  end

  it "raises and exception when a command is invalid" do
    expect {
      TeamSnap::Member.disable_member(TeamSnap.root_client, :foo => :bar)
    }.to raise_error(
      ArgumentError,
      "Invalid argument(s). Valid argument(s) are [:member_id]"
    )
  end

  it "raises an ArgumentError if no client sent to the command" do
    expect {
      TeamSnap::Member.disable_member
    }.to raise_error(
      ArgumentError
    )
  end

  it "can handle no argument errors generated by command" do
    expect {
      TeamSnap::Member.disable_member(TeamSnap.root_client)
    }.to raise_error(
      ArgumentError,
      "Invalid argument(s). Valid argument(s) are [:member_id]"
    )
  end

  it "adds .find if .search is available" do
    t = TeamSnap::Team.find(TeamSnap.root_client, 1)

    expect(t.id).to eq(1)
  end

  it "raises an exception if .find returns nothing" do
    expect {
      TeamSnap::Team.find(TeamSnap.root_client, 0)
    }.to raise_error(
      TeamSnap::NotFound,
      "Could not find a TeamSnap::Team with an id of '0'."
    )
  end

  it "can follow singular links" do
    m = TeamSnap::Member.find(TeamSnap.root_client, 3)
    t = m.team

    expect(t.id).to eq(1)
  end

  it "can handle links with no data" do
    m = TeamSnap::Member.find(TeamSnap.root_client, 1)
    as = m.assignments

    expect(as).to be_empty
  end

  it "can follow plural links" do
    t = TeamSnap::Team.find(TeamSnap.root_client, 1)
    ms = t.members

    expect(ms.size).to eq(17)
  end

  it "adds href to items" do
    m = TeamSnap::Member.find(TeamSnap.root_client, 1)

    expect(m.href).to eq("#{ROOT_TEST_URL}/members/1")
  end

  context "supports relations with expected behaviors" do
    let(:event) { TeamSnap::Event.find(TeamSnap.root_client, 1) }

    context "when a plural relation is called" do
      it "responds with an array of objects when successful" do
        a = event.availabilities
        expect(a.size).to be > 0
        expect(a).to be_an(Array)
      end

      it "responds with an empty array when no objects exist" do
        a = event.assignments
        expect(a.size).to eq(0)
        expect(a).to be_an(Array)
      end
    end

    context "when a singular relation is called" do
      it "responds with the object if it exists" do
        a = event.team
        expect(a).to be_a(TeamSnap::Team)
      end

      it "responds with nil if it does NOT exist" do
        a = event.division_location
        expect(a).to be_a(NilClass)
      end
    end
  end

  describe ".items" do
    it "returns all items for a base collection" do
      sports = TeamSnap::Sport.items(TeamSnap.root_client).map(&:name)
      expect(sports).to include("Basketball")
    end
  end
end
