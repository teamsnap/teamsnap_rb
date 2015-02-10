require "spec_helper"
require "teamsnap"

RSpec.describe "teamsnap_rb", :vcr => true do
  let!(:client) { TeamSnap::Client.new("") }

  it "can fetch a team" do
    t = TeamSnap::Team.find(1)

    expect(t).to_not be_nil
    expect(t.id).to eq(1)
  end
end
