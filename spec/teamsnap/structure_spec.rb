require "spec_helper"
require "teamsnap"

RSpec.describe "structure", :vcr => true do
  before(:all) do
    VCR.use_cassette("apiv3-init") do
      TeamSnap.init(
        :url => ROOT_TEST_URL,
        :client_id => "classic",
        :client_secret => "dont_tell_the_cops"
      )
    end
  end

  it "registers new classes via introspection of the root collection" do
    expect { TeamSnap::Team }.to_not raise_error
  end
end