# teamsnap-rails-6
Example of integrating the [TeamSnap](https://www.teamsnap.com) API with a
Rails 6 application.

## Setting Up

1. Clone this repo
2. [Register the application with
TeamSnap](http://developer.teamsnap.com/documentation/apiv3/authorization/#creating-oauth-2-credentials)
to get your OAuth client id and secret.

  NOTE: In your TeamsSnap application's settings, ensure that the oauth callback
is entered correctly: http://localhost:3000/auth/teamsnap/callback

3. Enter your token and secret from step 2 in `.env.docker`
4. Build docker container `docker-compose build`
5. Start the server: `docker-compose up`
6. Browse to http://localhost:3000/auth/teamsnap to initiate login.
7. Verify you are redirected back to your app with a valid authentication token.
8. You can now develop your app, storing the authentication tokens as required
   by your application's features.
