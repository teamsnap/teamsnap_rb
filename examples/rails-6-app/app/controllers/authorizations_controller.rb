class AuthorizationsController < ApplicationController
  def create
    # use auth_hash to access token. Store it in session, db, etc to make API
    # calls with.
    session[:teamsnap_auth_token] = auth_hash.credentials.token
    session[:teamsnap_user_id] = auth_hash.uid

    # render plain: auth_hash
    redirect_to teams_url
  end

  def logout
    reset_session
    flash[:notice] = "You have successfully logged out of OAuth."
    redirect_to root_url
  end

  protected

  def auth_hash
    request.env["omniauth.auth"]
  end
end
