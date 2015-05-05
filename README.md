An unofficial, hastily-written Oauth2 OmniAuth strategy for Yahoo. Uses the authorization flow described at https://developer.yahoo.com/oauth2/guide/flows_authcode/.

## Setup ##
`gem install omniauth-yahoo-oauth2`

Create an app at https://developer.yahoo.com/apps to get a Yahoo client ID and secret.

## Usage ##
```ruby
# In an initializer
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :yahoo_oauth2, yahoo_client_id, yahoo_secret,
    name: 'yahoo'
end
```

## Notes ##
OmniAuth doesn't currently have built-in support for Basic Authentication for retrieving OAuth tokens, so `YahooOauth2#build_access_token` handles this inline.

Yahoo returns an access_token, a refresh_token, and an expiration time for the access_token. They are available in the authentication hash in the callback:

```ruby
auth_info = request.env['omniauth.auth']
access_token = auth_info[:credentials][:token]
refresh_token = auth_info[:credentials][:refresh_token]
expires_at = auth_info[:credentials][:expires_at]
```

You can use the refresh_token to generate new access tokens:

```ruby
require 'oauth2'
require 'base64'

oauth_client = OAuth2::Client.new(YAHOO_CLIENT_ID, YAHOO_SECRET, {
  site: 'https://api.login.yahoo.com',
  authorize_url: '/oauth2/request_auth',
  token_url: '/oauth2/get_token',
})

auth = "Basic #{Base64.strict_encode64("#{YAHOO_CLIENT_ID}:#{YAHOO_SECRET}")}"

new_token = oauth_client.get_token({
  redirect_uri: YOUR_CALLBACK_URL,
  refresh_token: YOUR_REFRESH_TOKEN,
  grant_type: 'refresh_token',
  headers: { 'Authorization' => auth } })
```

## TODO ##
- Handle failure cases. (https://developer.yahoo.com/oauth2/guide/errors/)
- Test something. Anything.
