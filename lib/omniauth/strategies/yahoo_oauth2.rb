require 'omniauth/strategies/oauth2'
require 'base64'

module OmniAuth
  module Strategies
    class YahooOauth2 < OmniAuth::Strategies::OAuth2
      option :name, 'yahoo_oauth2'

      option :client_options,
             site: 'https://api.login.yahoo.com',
             authorize_url: '/oauth2/request_auth',
             token_url: '/oauth2/get_token'

      uid { access_token.params['xoauth_yahoo_guid'] }

      info do
        {
          name: raw_profile_info['givenName'],
          nickname: raw_profile_info['nickname'],
          location: raw_profile_info.dig['location'],
          image: raw_profile_info.dig('image', 'imageUrl'),
          urls: {
            Profile: raw_profile_info['profileUrl']
          },
          extra: {
            raw_info: raw_profile_info
          }
        }
      end

      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end

      def build_access_token
        verifier_code = request.params['code']

        auth = "Basic #{Base64.strict_encode64("#{options.client_id}:#{options.client_secret}")}"

        client.get_token(
          { redirect_uri: callback_url, code: verifier_code, grant_type: 'authorization_code', headers: { 'Authorization': auth } }
          .merge(token_params.to_hash(symbolize_keys: true)), deep_symbolize(options.auth_token_params)
        )
      end

      def raw_profile_info
        raw_profile_info_url = "https://social.yahooapis.com/v1/user/#{uid}/profile?format=json"
        @raw_profile_info ||= access_token.get(raw_profile_info_url).parsed['profile']
      end
    end
  end
end
