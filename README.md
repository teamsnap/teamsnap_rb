[![Code Climate](https://codeclimate.com/github/teamsnap/teamsnap_rb/badges/gpa.svg)](https://codeclimate.com/github/teamsnap/teamsnap_rb)
[![Test Coverage](https://codeclimate.com/github/teamsnap/teamsnap_rb/badges/coverage.svg)](https://codeclimate.com/github/teamsnap/teamsnap_rb)

# EARLY ACCESS

Please be aware there may be bugs, gremlins, and horrible issues; and you could be eaten by a grue. We are not responsible for any loss of life or limb (especially if you are eaten by a grue).

# TeamsnapRb

TeamsnapRb is a convenient wrapper around the faraday and the conglomerate gem that helps you talk to TeamSnap's APIv3.

## Installation

Add this line to your application's Gemfile:

    gem 'teamsnap_rb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install teamsnap_rb

## Usage

Needs to be updated; coming soon.

## Contributing

### Git Workflow

1. Fork it ( http://github.com/teamsnap/teamsnap_rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Testing teamsnap_rb

`./bin/rspec` will run the test suite.

### teamsnap_rb in IRB

```ruby
$ irb
> require 'teamsnap_rb'
=> true
> client_config = TeamsnapRb::Config.new(
>   client_id: "your_client_id_here",
>   client_secret: "ssshhhhhh!"
> )
> client = TeamsnapRb::Client.new("http://apiv3.teamsnap.com/", config: client_config)
=> # client object
> team = client.teams.search(:id => "your_team_id_here").first
=> # team object
```

In order to work on teamsnap_rb most effectively and efficiently, it'll he helpful
to have a TeamSnap account and teams so you can work with that data. You can
create a TeamSnap account [here](https://go.teamsnap.com) and you can then
authorize a client application using our [Cogsworth
service](https://auth.teamsnap.com).

With a client ID and secret in hand, you can begin interacting with the gem
using real data.
