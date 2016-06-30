require "spec_helper"
require "teamsnap"

RSpec.describe "uploading files", :vcr => true do
  let(:client_id) { "classic" }
  let(:client_secret) { "dont_tell_the_cops" }

  let(:client) {
    TeamSnap::Client.new({
      :url => ROOT_TEST_URL,
      :token => "7-js_frontend-dont_tell_the_cops"
    })
  }

  before(:all) do
    VCR.use_cassette("apiv3-init") do
      TeamSnap.init(
        :url => ROOT_TEST_URL,
        :client_id => "classic",
        :client_secret => "dont_tell_the_cops"
      )
    end
  end

  it "uploads a file" do
    file = File.open("support/teamsnap.png", "r")
    response = TeamSnap::Member
      .upload_member_photo(client, :member_id => "6", :file => file)
    expect(response.first).to be_a(TeamSnap::Member)
  end
end
