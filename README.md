# teamsnap_rb

[![Quality](http://img.shields.io/codeclimate/github/teamsnap/teamsnap_rb.svg)](https://codeclimate.com/github/teamsnap/teamsnap_rb)  
[![Coverage](http://img.shields.io/coveralls/teamsnap/teamsnap_rb.svg)](https://https://coveralls.io/r/teamsnap/teamsnap_rb)  
[![Build](http://img.shields.io/travis-ci/teamsnap/teamsnap_rb.svg)](https://travis-ci.org/teamsnap/teamsnap_rb)  
[![Dependencies](http://img.shields.io/gemnasium/teamsnap/teamsnap_rb.svg)](https://gemnasium.com/teamsnap/teamsnap_rb)  
[![License](http://img.shields.io/badge/license-MIT.svg)](http://opensource.org/licenses/MIT)  
[![Version](http://img.shields.io/gem/teamsnap/teamsnap_rb.svg)](https://rubygems.org/gems/teamsnap_rb)  

## Usage

_Note: You'll need an OAuth2 Token from TeamSnap._

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
