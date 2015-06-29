require "oauth2"

module YahooOauth2
  class AccessToken < OAuth2::AccessToken

    # adds redirect_uri=oob without which Yahoo will return 400 error
    def refresh!(params = {})
      super({redirect_uri: "oob"}.merge(params))
    end

  end
end
