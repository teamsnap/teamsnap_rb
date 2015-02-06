require "spec_helper"

vcr_options = {
  :cassette_name => "teams",
  :match_requests_on => [:host, :path, :body]
}
describe TeamSnap::Template, :vcr => vcr_options do
  let(:template) { TeamSnap::Collection.new(
    "http://localhost:3003/teams", {}, TeamSnap::Config.new
  ).template }

  describe "#new" do
    it "returns a template object from Collection#template" do
      expect(template).to be_a(TeamSnap::Template)
    end
  end

  describe "#build" do
    it "returns an empty hash when no attributes are passed in" do
      expect(template.build).to eq("template" => {})
    end

    it "returns a properly serialized template hash when attrs are passed in" do
      expect(template.build("name" => "Teamsters")).to eq(
        {
          "template"=> {
            "data"=>[{
              "name"=>"name", "value"=>"Teamsters"
            }]
          }
        }
      )
    end
  end

  describe "#data" do
    it "returns a Conglomerate::Array of data that can be passed into the template" do
      expect(template.data).to be_a(Conglomerate::Array)
    end
  end

  describe "POST /teams via Template#push" do
    it "returns a bad response (400) when the template fails to post" do
      expect(template.push("name" => "Teamsters").status).to eq(400)
    end

    it "returns a success (200) when the template posts with all required data" do
      expect(
        template.push(
          "name" => "Teamsters",
          "sport_id" => 1,
          "location_country" => "United States",
          "location_postal_code" => "80951",
          "time_zone" => "America/Denver"
        ).status
      ).to eq(201)
    end
  end
end
