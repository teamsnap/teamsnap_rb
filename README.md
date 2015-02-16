# teamsnap_rb

[![Code
Climate](https://codeclimate.com/github/teamsnap/teamsnap_rb/badges/gpa.svg)](https://codeclimate.com/github/teamsnap/teamsnap_rb)
[![Coverage
Status](https://coveralls.io/repos/teamsnap/teamsnap_rb/badge.png)](https://coveralls.io/r/teamsnap/teamsnap_rb)

## Usage

__Note: You'll need an OAuth2 Token from TeamSnap.__

```
λ bundle install
Fetching gem metadata from https://rubygems.org/..........
...
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
λ bundle exec rake console
[1] pry(main)> TeamSnap.init("abc123...", :url => "https://apiv3.teamsnap.com")
[2] pry(main)> t = TeamSnap::Team.find(1)
=> #<TeamSnap::Team::...>
[3] pry(main)> t.name
=> "TeamSnap"
[4] pry(main)> rs = client.bulk_load(:team_id => 1, :types => "team,member")
=> [#<TeamSnap::Team:...>,
 #<TeamSnap::Member:...>,
 # ...
 #<TeamSnap::Member:...>]
[5] pry(main)> rs[1].first_name
=> "Andrew"
```

## Todo

- Literate style docs?
- Cache items with threadsafe Hash (https://github.com/headius/thread_safe).
- Implement create, update and delete.
