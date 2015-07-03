require "spec_helper"
require "teamsnap"

RSpec.describe TeamSnap::Client do
  it "creates instance of client for token auth" do
    client = TeamSnap::Client.new(:token => "123")
  end

  it "creates instance of client for hmac auth" do
    client = TeamSnap::Client.new(:client_id => "123", :client_secret => "123")
  end

  it "creates instance of client for token auth with block" do
    client = TeamSnap::Client.new do |config|
      config.token = "123"
    end
  end

  it "creates instance of client for hmac auth with block" do
    client = TeamSnap::Client.new do |config|
      config.client_id = "123"
      config.client_secret = "123"
    end
  end

  it "overrides default url" do
    client = TeamSnap::Client.new do |config|
      config.client_id = "123"
      config.client_secret = "123"
      config.url = ""
    end
  end
end
