require "oauth2"
require 'base64'
require "yahoo_oauth2/access_token"

module YahooOauth2
  class Client < OAuth2::Client

    # convenience; sets correct client_options by default
    def initialize(client_id, client_secret, options = {}, &block)
      options = {
        site:          'https://api.login.yahoo.com',
        authorize_url: '/oauth2/request_auth',
        token_url:     '/oauth2/get_token',
      }.merge(options)
      super(client_id, client_secret, options, &block)
    end

    # Adds Basic Auth header, which is base64(client_id:client_secret)
    def get_token(params,
                  access_token_opts = {},
                  access_token_class = ::YahooOauth2::AccessToken)
      params[:headers] ||= {}
      params[:headers]["Authorization"] ||= token_authorization_header
      super(params, access_token_opts, access_token_class)
    end

    def token_authorization_header
      "Basic #{Base64.strict_encode64("#{id}:#{secret}")}"
    end

  end
end
