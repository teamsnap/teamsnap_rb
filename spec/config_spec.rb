require "spec_helper"

describe TeamsnapRb::Config do
  let(:config) { TeamsnapRb::Config.new }

  describe "#new" do
    it "uses sensible defaults when no options are passed in" do
      expect(config.authorization).to be_nil
      expect(config.access_token).to be_nil
      expect(config.client_secret).to be_nil
      expect(config.client_id).to be_nil
      expect(config.response_middleware).to eq([])
      expect(config.request_middleware).to eq([])
    end
  end
end
