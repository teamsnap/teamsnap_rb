require "teamsnap"

class TeamsController < ApplicationController
  def index
    @teams = TeamSnap::Team.active_teams(teamsnap_client, {:user_id => session[:teamsnap_user_id]})
  end
end