# TeamsnapRb

TeamsnapRb is a convenient wrapper around the faraday and the collection-json gem that helps you talk to TeamSnap's APIv3.

## Installation

Add this line to your application's Gemfile:

    gem 'teamsnap_rb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install teamsnap_rb

## Usage

```ruby
client = TeamsnapRb::Client.new # without authorization, so you can't see much

client = TeamsnapRb::Client.new(access_token: "oauth_access_token_here")

me = client.links.me
# => [#<TeamsnapRb::Collection>]

user = me[0]
# => #<TeamsnapRb::Item>

user.href
# => "https://apiv3.teamsnap.com/users/1"

user.links.teams.where(sport_id: 52)
# => [#<TeamsnapRb::Collection>, #<TeamsnapRb::Collection>]

user.links.teams.where(sport_id: 52).first.sport_id
# => 52
```

## Contributing

1. Fork it ( http://github.com/teamsnap/teamsnap_rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
