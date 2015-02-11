require "spec_helper"
require "teamsnap"

RSpec.describe "teamsnap_rb" do
  let!(:client) { TeamSnap::Client.new("") }

  it "registers new classes via introspection of the root collection" do
    expect { TeamSnap::Team }.to_not raise_error
  end
end
