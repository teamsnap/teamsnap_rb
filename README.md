# teamsnap_rb

[![Code
Climate](https://codeclimate.com/github/teamsnap/teamsnap_rb/badges/gpa.svg)](https://codeclimate.com/github/teamsnap/teamsnap_rb)
[![Coverage
Status](https://coveralls.io/repos/teamsnap/teamsnap_rb/badge.png)](https://coveralls.io/r/teamsnap/teamsnap_rb)

## Usage

First, fire up apiv3 on port 3000. Then follow the instructions below.

```
λ bundle install
Fetching gem metadata from https://rubygems.org/..........
...
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
λ ruby shane.rb
[1] pry(main)> t = TeamSnap::Team.find(1)
=> #<TeamSnap::Team::...>
[2] pry(main)> t.name
=> "Base Team"
[3] pry(main)> rs = client.bulk_load(:team_id => 1, :types => "team,member")
=> [#<TeamSnap::Team:...>,
 #<TeamSnap::Member:...>,
 #<TeamSnap::Member:...>,
 #<TeamSnap::Member:...>,
 #<TeamSnap::Member:...>,
 #<TeamSnap::Member:...>,
 #<TeamSnap::Member:...>,
 #<TeamSnap::Member:...>,
 #<TeamSnap::Member:...>,
 #<TeamSnap::Member:...>,
 #<TeamSnap::Member:...>]
[4] pry(main)> rs[1].first_name
=> "Manny"
```

## Todo

- Literate style docs?
- Enable parallel typhoeus
- Use vcr to record non-root collections to `tmp/`. Delete cassettes if 'version' changes on root collection.
  - Check if parallel typhoeus is faster than vcr cassettes.
- Ensure dynamic creation of classes is threadsafe. May require a mutex.
- Cache items with threadsafe Hash (https://github.com/headius/thread_safe).
  - Can Faraday cache requests already?
- Convert Items from Class to Virtus Value Object.
- Implement create, update and delete.
- Implement 'TeamSnap.me' (raise error if haven't init yet)
- Refactor!?!?!
