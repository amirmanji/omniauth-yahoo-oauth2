require 'omniauth/strategies/oauth2'
require 'base64'

module OmniAuth
  module Strategies
    class YahooOauth2 < OmniAuth::Strategies::OAuth2
      option :name, 'yahoo_oauth2'

      option :client_options, {
        site: 'https://api.login.yahoo.com',
        authorize_url: '/oauth2/request_auth',
        token_url: '/oauth2/get_token',
      }

      uid { access_token.params['xoauth_yahoo_guid'] }

      info do
        {
          name: raw_info['profile']['nickname'],
          nickname: raw_info['profile']['nickname'],
          gender: raw_info['profile']['gender'],
          language: raw_info['profile']['lang'],
          location: raw_info['profile']['location'],
          urls: {
            image: raw_info['profile']['image']['imageUrl'],
            profile: raw_info['profile']['profileUrl']
          }
        }
      end

      def build_access_token
        verifier = request.params['code']

        auth = "Basic #{Base64.strict_encode64("#{options.client_id}:#{options.client_secret}")}"

        token = client.get_token(
          { redirect_uri: callback_url, code: verifier, grant_type: 'authorization_code', headers: { 'Authorization' => auth } }.
          merge(token_params.to_hash(symbolize_keys: true)), deep_symbolize(options.auth_token_params))

        token
      end

      def raw_info
        raw_info_url = "https://social.yahooapis.com/v1/user/#{uid}/profile?format=json"
        @raw_info ||= access_token.get(raw_info_url).parsed
      end
    end
  end
end
