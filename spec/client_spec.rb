require "spec_helper"

module TeamsnapRb
  describe Client do
    describe "#new" do
      it "returns a new collection from the root URL" do
        client = Client.new
        expect(client).to be_a(Collection)
      end
    end
  end
end
