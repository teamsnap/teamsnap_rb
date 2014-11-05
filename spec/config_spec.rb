require "spec_helper"

module TeamsnapRb
  describe Config do
    describe "#access_token" do
      it "default value is nil" do
        Config.new.access_token = nil
      end
    end

    describe "#access_token=" do
      it "can set value" do
        config = Config.new
        config.access_token = "my_token"
        expect(config.access_token).to eq("my_token")
      end
    end

    describe "#client_secret" do
      it "default value is nil" do
        Config.new.client_secret = nil
      end
    end

    describe "#client_secret=" do
      it "can set value" do
        config = Config.new
        config.client_secret = "terces"
        expect(config.client_secret).to eq("terces")
      end
    end

    describe "#client_id" do
      it "default value is nil" do
        Config.new.client_id = nil
      end
    end

    describe "#client_id=" do
      it "can set value" do
        config = Config.new
        config.client_id = "eye_dee"
        expect(config.client_id).to eq("eye_dee")
      end
    end

    describe "#response_middleware" do
      it "default value is an empty array" do
        Config.new.response_middleware = []
      end
    end

    describe "#response_middleware=" do
      it "can set value" do
        config = Config.new
        config.response_middleware = [:middleware]
        expect(config.response_middleware).to eq([:middleware])
      end
    end

    describe "#request_middleware" do
      it "default value is an empty array" do
        Config.new.request_middleware = []
      end
    end

    describe "#request_middleware=" do
      it "can set value" do
        config = Config.new
        config.request_middleware = [:middleware]
        expect(config.request_middleware).to eq([:middleware])
      end
    end
  end
end
