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
  end
end
