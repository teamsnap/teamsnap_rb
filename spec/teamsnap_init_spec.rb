require "teamsnap"

RSpec.describe "teamsnap_rb" do
  let(:default_url) { TeamSnap::DEFAULT_URL }
  let(:specified_url) { "https://url-fun-zone.com" }
  let(:response) { Typhoeus::Response.new(
    code: 200, body: { :collection => { :links => [] } }.to_json
  ) }

  describe ".init" do
    it "requires token or client id and client secret" do
      expect {
        TeamSnap.init
      }.to raise_error(ArgumentError, "You must provide a :token or :client_id and :client_secret pair to '.init'")
    end

    it "initializes with default url and token auth" do
      Typhoeus.stub(%r(#{default_url})).and_return(response)

      TeamSnap.init(:token => "mytoken", :backup_cache => false)
    end

    it "requires client secret when given client id" do
      expect {
        TeamSnap.init(:client_id => "myclient")
      }.to raise_error(ArgumentError, "You must provide a :token or :client_id and :client_secret pair to '.init'")
    end

    it "initializes with default url and hmac auth" do
      Typhoeus.stub(/#{default_url}/).and_return(response)

      TeamSnap.init(
        :client_id => "myclient", :client_secret => "mysecret", :backup_cache => false
      )
    end

    it "allows url to be specified" do
      Typhoeus.stub(/#{specified_url}/).and_return(response)

      TeamSnap.init(
        :client_id => "myclient", :client_secret => "mysecret", :backup_cache => false,
        :url => specified_url
      )
    end
  end
end
