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

## Auth Mechanisms

There are two primary auth mechanisms.

1. User Token Based Auth
2. HMAC Auth

Token based auth allows for passing along a user's token in the request to
authorize certain actions enabled for a given user. For example, sending a
user's token when inviting members to a team will be authorized based on that
user's role on the team.

HMAC based authentication is typically used less for user centric operations and
moreso for internal services and operations.

Occassionaly, a given application may prefer to use both authentication
mechanisms. For example, an application that needs to initialize TeamSnap
outside of a user context may be authorized as an HMAC-approved application.
In those context's, the application can initialize via HMAC and switch
authentication mechanisms in subsequent requests, like so:

```ruby
λ irb
> TeamSnap.init(
>    :client_secret => "abc123...",
>    :client_id => "321cba...",
>    :url => "https://apiv3.teamsnap.com"
> )
> team = TeamSnap::Team.find(1)
=> #<TeamSnap::Team::...>
> team.name
=> "TeamSnap"
> TeamSnap::Team.invite(:team_id => 1, :member_id => 2)
=> "You are not authorized to access this resource"
> TeamSnap.auth_with(:token => "1-classic-dont_tell_the_cops")
=> #<Faraday::Connection:0x00...>
> TeamSnap::Team.invite(:team_id => 1, :member_id => 2)
=> "Success!"
```

Using the `auth_with` method creates a new Faraday client that has been built
with the update auth middleware. By default any subsequent requests using
TeamSnap will continue to use that client. In order to make any subsequent
requests, either as a different or going back to an HMAC style with require the
resetting of the `auth_with` credentials prior to making the request.

## Backup Cache

By default when calling TeamSnap.init(...), there is a backup cache of the API root response used
to setup all relevant classes. This is primarily used so CI testing and deploy jobs do not have to
connect to the API to complete.

This creates a .teamsnap\_rb file in your ./tmp directory (./tmp/.teamsnap_rb). If you would like to turn this functionality
off, just set ```:backup_cache => false``` in your init options. Alternatively, you can set the location
of the backup by passing a string location of where to store the file. e.g.
```:backup_cache => "./another/location/.teamsnap_rb_file"```

## Todo

- Literate style docs?
- Cache items with threadsafe Hash (https://github.com/headius/thread_safe).
- Implement create, update and delete.
