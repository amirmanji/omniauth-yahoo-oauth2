# lib/omniauth/strategies/aol_oauth2.rb
require_relative './yahoo_oauth2'

module OmniAuth
  module Strategies
    class AolOAuth2 < YahooOAuth2
      option :name, "aol"

      # I don't remember if OmniAuth deep merges options, but it's better to
      # duplicate `authorize_url` and `token_url` than to duplicate the entire class.  :)
      option :client_options, {
        site:              "https://api.login.aol.com",
        authorize_url:     "/oauth2/request_auth",
        token_url:         "/oauth2/get_token",
      }

      option :allowed_jwt_issuers, %w[
        https://api.login.aol.com
        api.login.aol.com
        login.aol.com
      ]
    end
  end
end

