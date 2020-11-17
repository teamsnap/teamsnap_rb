Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :teamsnap, ENV['TEAMSNAP_CLIENT_ID'], ENV['TEAMSNAP_CLIENT_SECRET'], scope: "read write"
end
OmniAuth.config.logger = Rails.logger
