require "spec_helper"
require "teamsnap"

RSpec.describe "teamsnap__item", :vcr => true do
  before(:all) do
    VCR.use_cassette("apiv3-init") do
      TeamSnap.init(
        :url => ROOT_TEST_URL,
        :client_id => "classic",
        :client_secret => "dont_tell_the_cops"
      )
    end
  end

  describe ".load_items" do
    it "returns TeamSnap::Object for the given json item" do
      collection = {
        :items => [
          {
            :href => "http://localhost:3000/teams/10",
            :data => [
              {
                :name => "id",
                :value => 10
              },
              {
                :name => "type",
                :value => "team"
              },
              {
                :name => "division_name",
                :value => nil
              },
              {
                :name => "division_id",
                :value => nil
              },
              {
                :name => "is_archived_season",
                :value => false
              },
              {
                :name => "is_retired",
                :value => false
              },
              {
                :name => "league_name",
                :value => nil
              },
              {
                :name => "league_url",
                :value => nil
              },
              {
                :name => "is_in_league",
                :value => false
              },
              {
                :name => "location_country",
                :value => "United States"
              },
              {
                :name => "location_postal_code",
                :value => "80951"
              },
              {
                :name => "location_latitude",
                :value => nil
              },
              {
                :name => "location_longitude",
                :value => nil
              },
              {
                :name => "name",
                :value => "Cheerleading Team"
              },
              {
                :name => "plan_id",
                :value => 33
              },
              {
                :name => "billed_at",
                :value => "2016-02-08T00:00:00.000+00:00"
              },
              {
                :name => "season_name",
                :value => nil
              },
              {
                :name => "sport_id",
                :value => 31
              },
              {
                :name => "time_zone_description",
                :value => "Mountain Time (US & Canada)"
              },
              {
                :name => "time_zone_iana_name",
                :value => "America/Denver"
              },
              {
                :name => "time_zone_offset",
                :value => "-07:00"
              },
              {
                :name => "updated_at",
                :value => "2016-02-08T20:04:21Z",
                :type => "DateTime"
              },
              {
                :name => "created_at",
                :value => "2016-02-08T20:04:06Z",
                :type => "DateTime"
              },
              {
                :name => "has_reached_roster_limit",
                :value => false
              },
              {
                :name => "roster_limit",
                :value => 4000
              },
              {
                :name => "has_exportable_media",
                :value => false
              },
              {
                :name => "can_export_media",
                :value => false
              },
              {
                :name => "last_accessed_at",
                :value => nil,
                :type => "DateTime"
              },
              {
                :name => "media_storage_used",
                :value => 0
              },
              {
                :name => "humanized_media_storage_used",
                :value => "0 B"
              }
            ],
            :links => [
              {
                :rel => "logo",
                :href => "http://example.com/logo.png"
              }
            ]
          }
        ]
      }

      item = TeamSnap::Item.load_items(TeamSnap.root_client, collection)[0]

      expect(item.class).to eq(TeamSnap::Team)
      expect(item.logo_url).to eq("http://example.com/logo.png")
      expect(item.attributes[:logo_url]).to eq("http://example.com/logo.png")
    end
  end
end
