# teamsnap_rb

[![Dependencies](http://img.shields.io/gemnasium/teamsnap/teamsnap_rb.svg)](https://gemnasium.com/teamsnap/teamsnap_rb)
[![Quality](http://img.shields.io/codeclimate/github/teamsnap/teamsnap_rb.svg)](https://codeclimate.com/github/teamsnap/teamsnap_rb)
[![Coverage](http://img.shields.io/coveralls/teamsnap/teamsnap_rb.svg)](https://https://coveralls.io/r/teamsnap/teamsnap_rb)
[![Build](http://img.shields.io/travis-ci/teamsnap/teamsnap_rb.svg)](https://travis-ci.org/teamsnap/teamsnap_rb)
[![Version](http://img.shields.io/gem/v/teamsnap_rb.svg)](https://rubygems.org/gems/teamsnap_rb)
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)

## Usage

_Note: You'll need an OAuth2 Token from TeamSnap. Checkout our API docs
[here](http://developer.teamsnap.com/documentation/apiv3/)_

```
λ gem install teamsnap_rb
λ irb
> TeamSnap.init(:token => "abc123...", :url => "https://apiv3.teamsnap.com")
> t = TeamSnap::Team.find(1)
=> #<TeamSnap::Team::...>
> t.name
=> "TeamSnap"
> rs = client.bulk_load(:team_id => 1, :types => "team,member")
=> [#<TeamSnap::Team:...>,
 #<TeamSnap::Member:...>,
 # ...
 #<TeamSnap::Member:...>]
> rs[1].first_name
=> "Andrew"
```

## Todo

- Literate style docs?
- Cache items with threadsafe Hash (https://github.com/headius/thread_safe).
- Implement create, update and delete.
