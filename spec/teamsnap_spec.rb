require "spec_helper"
require "teamsnap"

RSpec.describe "teamsnap_rb", :vcr => true do
  let(:default_url) { TeamSnap::DEFAULT_URL }
  let(:specified_url) { "https://url-fun-zone.com" }
  let(:response) { Typhoeus::Response.new(
    code: 200,
    headers: { "content-type" => "application/json" },
    body: { :collection => { :links => [] } }.to_json
  ) }
  let(:client_id) { "classic" }
  let(:client_secret) { "dont_tell_the_cops" }

  describe ".init" do
    it "requires token or client id and client secret" do
      expect {
        TeamSnap.init
      }.to raise_error(ArgumentError, "You must provide a :token or :client_id and :client_secret pair to '.init'")
    end

    it "initializes with default url and token auth" do
      Typhoeus.stub(%r(#{default_url})).and_return(response)

      TeamSnap.init(:token => "mytoken")
    end

    it "requires client secret when given client id" do
      expect {
        TeamSnap.init(:client_id => "myclient")
      }.to raise_error(ArgumentError, "You must provide a :token or :client_id and :client_secret pair to '.init'")
    end

    it "initializes with default url and hmac auth" do
      Typhoeus.stub(/#{default_url}/).and_return(response)

      TeamSnap.init(
        :client_id => "myclient", :client_secret => "mysecret"
      )
    end

    it "allows url to be specified" do
      Typhoeus.stub(/#{specified_url}/).and_return(response)

      TeamSnap.init(
        :client_id => "myclient", :client_secret => "mysecret",
        :url => specified_url
      )
    end
  end

  describe ".run" do
    context "works when" do
      after(:each) do
        VCR.use_cassette("apiv3-init") do
          TeamSnap.init(
            :url => ROOT_TEST_URL,
            :client_id => client_id,
            :client_secret => client_secret
          )
        end
      end

      it "calls client_send with the given attributes" do
        expect(TeamSnap).to receive("client_send").with(any_args).and_call_original
      end

      it "the API responds and loads the collection" do
        expect(TeamSnap::Response).to receive("load_collection").with(any_args).and_call_original
      end
    end

    it "processes the response" do
      VCR.use_cassette("apiv3-init") do
        TeamSnap.init(
          :url => ROOT_TEST_URL,
          :client_id => client_id,
          :client_secret => client_secret
        )
      end
      TeamSnap.stub(:url).and_return(ROOT_TEST_URL)
      client = TeamSnap::Client.new({
        :client_id => client_id,
        :client_secret => client_secret
      })
      via = :get
      href = "/"
      args = {}

      expect(TeamSnap.run(client, via, href, args).fetch(:links)).to_not be_empty
      expect(TeamSnap.run(client, via, href, args).fetch(:queries)).to_not be_empty
      expect(TeamSnap.run(client, via, href, args).fetch(:commands)).to_not be_empty
      expect(TeamSnap.run(client, via, href, args).fetch(:href)).to eq(ROOT_TEST_URL + href)
    end
  end

  describe ".client_send" do
    let(:client) {
      TeamSnap::Client.new({
        :client_id => client_id,
        :client_secret => client_secret
      })
    }

    context "when sent a known `via`" do
      it "calls GET on the given client" do
        TeamSnap.stub(:url).and_return(ROOT_TEST_URL)
        via = :get
        href = "/"
        args = {}

        expect(client).to receive(via).with(href, args).and_call_original
        TeamSnap.client_send(client, via, href, args)
      end

      it "calls DELETE on the given client" do
        TeamSnap.stub(:url).and_return(ROOT_TEST_URL)
        via = :delete
        href = "/"
        args = {}

        expect(client).to receive(via).with(href, args).and_call_original
        TeamSnap.client_send(client, via, href, args)
      end

      it "calls POST on the given client" do
        TeamSnap.stub(:url).and_return(ROOT_TEST_URL)
        via = :post
        href = "/"
        args = {}

        expect(client).to receive(via).with(href).and_call_original
        TeamSnap.client_send(client, via, href, args)
      end

      it "calls PATCH on the given client" do
        TeamSnap.stub(:url).and_return(ROOT_TEST_URL)
        via = :patch
        href = "/"
        args = {}

        expect(client).to receive(via).with(href).and_call_original
        TeamSnap.client_send(client, via, href, args)
      end
    end

    context "when sent unknown `via`" do
      it "responds with an error" do
        TeamSnap.stub(:url).and_return(ROOT_TEST_URL)

        expect {
          TeamSnap.client_send(client, :unknown, "/", {})
        }.to raise_error(
          TeamSnap::Error,
          "Don't know how to run `unknown`"
        )
      end

      it "responds with an error" do
        TeamSnap.stub(:url).and_return(ROOT_TEST_URL)

        expect {
          TeamSnap.client_send(client, :head, "/", {})
        }.to raise_error(
          TeamSnap::Error,
          "Don't know how to run `head`"
        )
      end

      it "responds with an error" do
        TeamSnap.stub(:url).and_return(ROOT_TEST_URL)

        expect {
          TeamSnap.client_send(client, :options, "/", {})
        }.to raise_error(
          TeamSnap::Error,
          "Don't know how to run `options`"
        )
      end

      it "responds with an error" do
        TeamSnap.stub(:url).and_return(ROOT_TEST_URL)

        expect {
          TeamSnap.client_send(client, :trace, "/", {})
        }.to raise_error(
          TeamSnap::Error,
          "Don't know how to run `trace`"
        )
      end
    end
  end

  describe ".bulk_load" do
    before(:all) do
      VCR.use_cassette("apiv3-init") do
        TeamSnap.init(
          :url => ROOT_TEST_URL,
          :client_id => "classic",
          :client_secret => "dont_tell_the_cops"
        )
      end
    end

    it "can use bulk load" do
      cs = TeamSnap.bulk_load(
        TeamSnap.root_client,
        :team_id => 1,
        :types => "team,member"
      )

      expect(cs).to_not be_empty
      expect(cs.size).to eq(18)
      expect(cs[0]).to be_a(TeamSnap::Team)
      expect(cs[0].id).to eq(1)
      cs[3..17].each.with_index(4) do |c, idx|
        expect(c).to be_a(TeamSnap::Member)
        expect(c.id).to eq(idx)
      end
    end

    it "can handle an empty bulk load" do
      cs = TeamSnap.bulk_load(
        TeamSnap.root_client,
        :team_id => 0,
        :types => "team,member"
      )

      expect(cs).to be_empty
    end

    it "expects a client as the first parameter" do
      expect {
        TeamSnap.bulk_load
      }.to raise_error(
        ArgumentError,
        "wrong number of arguments (0 for 1+)"
      )
    end

    it "can handle an error with bulk load" do
      expect {
        TeamSnap.bulk_load(TeamSnap.root_client)
      }.to raise_error(
        TeamSnap::Error,
        "You must include a team_id parameter"
      )
    end
  end

 end
