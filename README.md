# teamsnap_rb

[![Build](https://travis-ci.org/teamsnap/teamsnap_rb.svg?branch=master)](https://travis-ci.org/teamsnap/teamsnap_rb)
[![Gem Version](https://badge.fury.io/rb/teamsnap_rb.svg)](https://badge.fury.io/rb/teamsnap_rb)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Usage

_Note: You'll need an OAuth2 Token from TeamSnap. Checkout our API docs
[here](http://developer.teamsnap.com/documentation/apiv3/)_

    λ gem install teamsnap_rb
    λ irb
    require "teamsnap"
    => true
    TeamSnap.init(:token => XXXXX)
    => true

    # Now you have your base connection to the API under:
    TeamSnap.root_client
    => #<TeamSnap::Client:...>

    # The below imply usage of:
    client = TeamSnap.root_client

    t = TeamSnap::Team.find(client, 1)
    => #<TeamSnap::Team::...>
    t.name
    => "TeamSnap"
    rs = client.bulk_load(client, {:team_id => 1, :types => "team,member"})
    => [
    =>   #<TeamSnap::Team:...>,
    =>   #<TeamSnap::Member:...>,
    =>   # ...
    =>   #<TeamSnap::Member:...>
    => ]
    rs[1].first_name
    => "Andrew"


    #########################
         Class Syntax
    #########################
     - raises error on exception
     - returns Object(TeamSnap::Class) / Objects(Array) as response

    # find
    team = TeamSnap::Team.find(client, XXX)

    # create
    team = TeamSnap::Team.create(client, {:attribute_name => value})

    # update
    team = TeamSnap::Team.update(client, id, {:attribute_name => value})

    # delete
    no_team = TeamSnap::Team.delete(client, id)

    # search
    teams = TeamSnap::Team.search(client, {:filter_on => filter_value})

    # command
    team = TeamSnap::Team.command_name(client, {:attr => val})


    #########################
         Api Class Syntax
    #########################
     - returns TeamSnap::Response object with select methods
     - optionally converts attributes hash into template: { data: {}}

    # find
    response = TeamSnap::Api.run(client, :find, :members, 1)
    => #<TeamSnap::Response:...>
    response.success?
    => true
    member = response.objects.first
    => #<TeamSnap::Member:...>
    response.errors?
    => false
    response.message
    => "Data retrieved successfully"

    # create
    response = TeamSnap::Api.run(client, :create, TeamSnap::Member, {:attr_name => attr_value}, true)
    => #<TeamSnap::Response:...>
    response.success?
    => false
    response.errors?
    => true
    response.message
    => "first_name can't be blank; team_id can't be blank"

    # update
    TeamSnap::Api.run(client, :update, :member, {}, true)
    => #<TeamSnap::Response:...>

    # delete
    TeamSnap::Api.run(client, :delete, :members, id)
    => #<TeamSnap::Response:...>

    # search & other queries
    TeamSnap::Api.run(client, :search, TeamSnap::Member, {:team_id => some_team_id})
    => #<TeamSnap::Response:...>

    # commands
    TeamSnap::Api.run(client, :command, :member, {:optional_attr => value})
    => #<TeamSnap::Response:...>


    #########################
       Client Object Calls
    #########################
     - returns TeamSnap::Response object with select methods
     - automatically translates attributes to / from template: { data: {}}

    # find
    client.api(:find, :forum_posts, 1)
    => #<TeamSnap::Response:...>

    # search and other 'queries' (arguments patch 'as-is')
    client.api(:search, TeamSnap::ForumPost, {:forum_topic_id => 2})
    => #<TeamSnap::Response:...>

    # create (arguments post in template data format)
    client.api(:create, :forum_post, forum_post_success)
    => #<TeamSnap::Response:...>

    # update (arguments post in template data format)
    client.api(:update, TeamSnap::ForumPost, forum_patch_success)
    => #<TeamSnap::Response:...>

    # delete
    client.api(:delete, :forum_posts, 1)
    => #<TeamSnap::Response:...>

    # commands (arguments post 'as-is')
    client.api(:command_name, :forum_post, {})
    => #<TeamSnap::Response:...>

    # queries (arguments sent in href key/value pairs)
    client.api(:query_name, :members, {})
    => #<TeamSnap::Response:...>



## Todo

- Cache items with threadsafe Hash (https://github.com/headius/thread_safe).
