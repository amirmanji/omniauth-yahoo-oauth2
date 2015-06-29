require "yahoo_oauth2/client"
require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class YahooOauth2 < OmniAuth::Strategies::OAuth2
      option :name, 'yahoo_oauth2'

      uid { access_token.params['xoauth_yahoo_guid'] }

      info do
        {
          nickname: raw_info['profile']['nickname'],
          first_name: raw_info["givenName"],
          last_name:  raw_info["familyName"],
          email: preferred_email,
          gender: raw_info['profile']['gender'],
          language: raw_info['profile']['lang'],
          location: raw_info['profile']['location'],
          urls: {
            image: raw_info['profile'].fetch('image', {})['imageUrl'],
            profile: raw_info['profile']['profileUrl']
          }
        }
      end

      def client
        ::YahooOauth2::Client.new(
          options.client_id,
          options.client_secret,
          deep_symbolize(options.client_options)
        )
      end

      def raw_info
        raw_info_url =
          "https://social.yahooapis.com/v1/user/#{uid}/profile?format=json"
        @raw_info ||= access_token.get(raw_info_url).parsed
      end

      def preferred_email
        emails = raw_info["profile"].fetch("emails",[])
        email  = emails.find {|e| e["primary"] } || emails.first
        email && email["handle"]
      end

    end
  end
end
