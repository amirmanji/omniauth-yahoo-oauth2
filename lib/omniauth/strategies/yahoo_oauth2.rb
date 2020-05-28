# frozen_string_literal: true

require "jwt"
require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class YahooOauth2 < OmniAuth::Strategies::OAuth2

      OPEN_ID_CONNECT_SCOPES = "openid,profile,email"

      ALLOWED_ISSUERS = %w[
        https://api.login.yahoo.com
        api.login.yahoo.com
        login.yahoo.com
      ].freeze

      option :name, 'yahoo'

      option :userinfo_url, "/openid/v1/userinfo"

      option :client_options, {
        site:              "https://api.login.yahoo.com",
        authorize_url:     "/oauth2/request_auth",
        token_url:         "/oauth2/get_token",
      }

      option :skip_jwt, false
      option :jwt_leeway, 300

      option :authorize_params, {
        response_type: 'code',
      }

      option :authorize_options, %i[
        language
        login_hint
        max_age
        prompt
        redirect_uri
        scope
        state
      ]

      uid { raw_info['sub'] }

      info do
        prune!({
          name:       raw_info["name"],
          email:      verified_email,
          unverified_email: raw_info['email'],
          email_verified:   raw_info["email_verified"],
          first_name: raw_info["given_name"],
          last_name:  raw_info["family_name"],
          nickname:   raw_info["nickname"],
          gender:     raw_info["gender"],
          locale:     raw_info['locale'],
          image:      raw_info['picture'],
          phone:      raw_info["phone_number"],
          phone_verified: raw_info["phone_number_verified"],
          urls: {
            profile: raw_info['profile'],
            website: raw_info['website'],
          },
        })
      end

      # n.b. renamed raw_info to userinfo. Userinfo is part of the OIDc standard.
      extra do
        hash = {}
        hash[:userinfo] = raw_info unless skip_info?
        hash[:id_token] = access_token["id_token"]
        hash[:id_info]  = decode_info_token
        prune! hash
      end

      def raw_info
        @raw_info ||= access_token.get(userinfo_url).parsed
      end

      private

      # This follows the example in omniauth-google-oauth2.
      #
      # Probably better to set the redirect_uri as a client option when creating
      # the client, because OAuth2::Client knows how to handle it, but that
      # requires updating OmniAuth::Strategies::OAuth2.
      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end

      def userinfo_url
        options.client_options.site + options.userinfo_url
      end

      # This is copied from the omniauth-google-oauth2 gem
      def verified_email
        raw_info['email_verified'] ? raw_info['email'] : nil
      end

      # This is copied from the omniauth-google-oauth2 gem
      def prune!(hash)
        hash.delete_if do |_, v|
          prune!(v) if v.is_a?(Hash)
          v.nil? || (v.respond_to?(:empty?) && v.empty?)
        end
      end

      # super saves SecureRandom state to session and merges authorize_options
      #
      # This follows the example in omniauth-google-oauth2 and
      # merges any request param with the same name as an authorize_option.
      # It then saves state to the session (in case it was overwritten).
      #
      # Probably the better way to handle this is to build it into "options_for"
      # and have another option (e.g. authorize_request_params).
      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            unless [nil, ''].include?(request.params[k.to_s])
              params[k] = request.params[k.to_s]
            end
            session['omniauth.state'] = params[:state] if params[:state]
          end
        end
      end

      # This is copied from the omniauth-google-oauth2 gem
      def decode_info_token
        unless options[:skip_jwt] || access_token['id_token'].nil?
          decoded = ::JWT.decode(access_token['id_token'], nil, false).first

          # We have to manually verify the claims because the third parameter to
          # JWT.decode is false since no verification key is provided.
          ::JWT::Verify.verify_claims(decoded,
                                      verify_iss: true,
                                      iss: ALLOWED_ISSUERS,
                                      verify_aud: true,
                                      aud: options.client_id,
                                      verify_sub: false,
                                      verify_expiration: true,
                                      verify_not_before: true,
                                      verify_iat: true,
                                      verify_jti: false,
                                      leeway: options[:jwt_leeway])

          decoded
        end
      end

    end
  end
end
