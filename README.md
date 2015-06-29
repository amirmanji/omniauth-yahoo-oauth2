## omniauth-yahoo-oauth2 ##

An unofficial, hastily-written Oauth2 OmniAuth strategy for Yahoo. Uses the
authorization flow described at
https://developer.yahoo.com/oauth2/guide/flows_authcode/.

Built using https://github.com/intridea/omniauth-oauth2.

## Setup ##
`gem install omniauth-yahoo-oauth2`

Create an app at https://developer.yahoo.com/apps to get a Yahoo client ID and
secret.

## Usage ##
```ruby
# In an initializer
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :yahoo_oauth2, yahoo_client_id, yahoo_secret, name: 'yahoo'
end
```

See https://github.com/intridea/omniauth for Omniauth instructions.

## Notes ##

OmniAuth doesn't currently have built-in support for Basic Authentication for
retrieving OAuth2 tokens, so `YahooOauth2::Client` overrides
`OAuth2::Client#get_token`.  Yahoo also requires `redirect_uri` to be set when
refreshing the `access_token`, so `YahooOauth2::AccessToken` overrides
`OAuth2::AccessToken#refresh!` to handle that.

As with other OAuth2 providers, Yahoo returns an `access_token`, a
`refresh_token`, and an expiration time for the `access_token`. They are
available in the credentials hash in the callback:

```ruby
credentials = request.env.fetch('omniauth.auth').fetch(:credentials)
tokens_hash = {
  access_token:  credentials[:token],
  refresh_token: credentials[:refresh_token],
  expires_at:    credentials[:expires_at]
}
```

They should be saved to your application's database.  You can use the
`access_token` directly or use `YahooOauth2::AccessToken` for requests:

```ruby
client = YahooOauth2::Client.new(YAHOO_CLIENT_ID, YAHOO_SECRET)
token  = YahooOauth2::AccessToken.from_hash(client, tokens_hash)
token.get(
  "https://social.yahooapis.com/v1/user/#{uid}/profile?format=json"
).parsed
```

And to refresh the access token once it has expired:

```ruby
old_token = YahooOauth2::AccessToken.from_hash(client, tokens_hash)
if old_token.expired?
  new_token = old_token.refresh!
  new_token.to_hash # => update your database with this
end
```

## TODO ##
- Handle failure cases. (https://developer.yahoo.com/oauth2/guide/errors/)
- Test something. Anything.
