require "spec_helper"

describe TeamsnapRb do
  describe "#configure" do
    before :each do
      TeamsnapRb.configure do |config|
        config.access_token = "my_token"
        config.client_secret = "terces"
        config.client_id = "eye_dee"
        config.request_middleware = [:request_middleware]
        config.response_middleware = [:response_middleware]
      end
    end

    it "returns the correct access token" do
      expect(TeamsnapRb.config.access_token).to be_a(String)
      expect(TeamsnapRb.config.access_token).to eq("my_token")
    end

    it "returns the correct client_secret" do
      expect(TeamsnapRb.config.client_secret).to be_a(String)
      expect(TeamsnapRb.config.client_secret).to eq("terces")
    end

    it "returns the correct client_id" do
      expect(TeamsnapRb.config.client_id).to be_a(String)
      expect(TeamsnapRb.config.client_id).to eq("eye_dee")
    end

    it "returns the correct request_middleware" do
      expect(TeamsnapRb.config.request_middleware).to be_a(Array)
      expect(TeamsnapRb.config.request_middleware).to eq([:request_middleware])
    end

    it "returns the correct response_middleware" do
      expect(TeamsnapRb.config.response_middleware).to be_a(Array)
      expect(TeamsnapRb.config.response_middleware).to eq([:response_middleware])
    end
  end
end
