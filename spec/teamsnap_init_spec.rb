require "spec_helper"
require "teamsnap"

RSpec.describe "teamsnap_rb", :vcr => true do
  describe ".init" do
    it "requires token or client id and client secret" do
      expect {
        TeamSnap.init
      }.to raise_error(ArgumentError, "You must provide a :token or :client_id and :client_secret pair to '.init'")
    end

    it "initializes with default url and token auth" do
      expect {
        TeamSnap.init(:token => "mytoken", :backup_cache => false)
      }.to raise_error(TeamSnap::Error, /You are not authorized to access this resource/)
    end

    it "requires client secret when given client id" do
      expect {
        TeamSnap.init(:client_id => "myclient")
      }.to raise_error(ArgumentError, "You must provide a :token or :client_id and :client_secret pair to '.init'")
    end

    it "initializes with default url and hmac auth" do
      expect {
        TeamSnap.init(:client_id => "myclient", :client_secret => "mysecret",
                      :backup_cache => false)
      }.to raise_error(TeamSnap::Error, /You are not authorized to access this resource/)
    end

    it "allows url to be specified" do
      connection = instance_double("Faraday::Connection")
      response = instance_double("Faraday::Response")
      allow(connection).to receive(:get) { response }
      allow(response).to receive(:success?) { false }
      allow(connection).to receive(:in_parallel) { false }

      expect(Faraday).to receive(:new).with(hash_including(
        :url => "https://api.example.com")) { connection }

      TeamSnap.init(:token => "mytoken", :url => "https://api.example.com")
    end
  end
end
