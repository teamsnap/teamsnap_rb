require "spec_helper"
require "teamsnap"

RSpec.describe TeamSnap::Client do
  describe "#initialize" do
    it "create instance of client for token auth with block" do
      client = TeamSnap::Client.new do |config|
        config.token = "token"
      end
      expect(client.configuration.token).to eq("token")
    end

    it "create instance of client for hmac auth with block" do
      client = TeamSnap::Client.new do |config|
        config.client_id = "123"
        config.client_secret = "abc"
      end
      expect(client.configuration.client_id).to eq("123")
      expect(client.configuration.client_secret).to eq("abc")
    end

    it "use default url" do
      client = TeamSnap::Client.new do |config|
        config.client_id = "123"
        config.client_secret = "123"
      end
      expect(client.configuration.url).to eq("https://api.teamsnap.com/v3/")
    end

    it "override default url" do
      client = TeamSnap::Client.new do |config|
        config.client_id = "123"
        config.client_secret = "123"
        config.url = "https://url-fun-zone.com"
      end
      expect(client.configuration.url).to eq("https://url-fun-zone.com")
    end
  end

  describe "#find", :vcr => true do
    it "blah" do
      client = TeamSnap::Client.new do |config|
        config.token = "1-classic-dont_tell_the_cops"
        config.url = ROOT_TEST_URL
      end
      t = client.team.find(1)
    end
  end
end
