class ApplicationController < ActionController::Base
  def current_user
    @current_user ||= begin
      me_response = TeamSnap.run(teamsnap_client, :get, "/me")
      TeamSnap::Item.load_items(teamsnap_client, me_response).first
    end
  end

  def teamsnap_client
    @teamsnap_client ||= begin
      TeamSnap::Client.new(token: session[:teamsnap_auth_token])
    end
  end
end
