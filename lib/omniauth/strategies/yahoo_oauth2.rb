require "yahoo_oauth2/client"
require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class YahooOauth2 < OmniAuth::Strategies::OAuth2
      option :name, 'yahoo_oauth2'

      uid { access_token.params['xoauth_yahoo_guid'] }

      info do
        prune!({
          name:       profile["nickname"],
          nickname:   profile['nickname'],
          first_name: profile["givenName"],
          last_name:  profile["familyName"],
          email:      preferred_email,
          location:   profile['location'],
          image:      profile['imageUrl'],
          phone:      profile.fetch("phones", []).join(", "),
          urls: {
            profile: profile['profileUrl'],
          },
        })
      end

      extra do
        hash = {}
        hash[:raw_info] = raw_info unless skip_info?
        prune! hash
      end

      def profile
        raw_info.fetch("profile")
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

      private

      def prune!(hash)
        hash.delete_if do |_, v|
          prune!(v) if v.is_a?(Hash)
          v.nil? || (v.respond_to?(:empty?) && v.empty?)
        end
      end

      def preferred_email
        emails = raw_info["profile"].fetch("emails",[])
        email  = emails.find {|e| e["primary"] } || emails.first
        email && email["handle"]
      end

    end
  end
end
