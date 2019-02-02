module OmniAuth
  module Strategies
    # Strategy getting oauth2 authorization from a Ekklesia identity server.
    # client id + secret and Ekklesia site url must be passed like:
    #
    # omniauth.provider(
    #   :ekklesia,
    #   CLIENT_ID,
    #   CLIENT_SECRET,
    #   client_options: { site: SITE_URL }
    # )
    class Ekklesia < OmniAuth::Strategies::OAuth2
      option :client_options,
             authorize_url: '/oauth2/authorize/',
             token_url: '/oauth2/token/'

      uid { raw_info['auid'] }

      info do
        {
          nickname: raw_info['username']
        }
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def raw_info
        info = access_token.get('/api/v1/user/auid/').parsed
        info.merge!(access_token.get('/api/v1/user/membership/').parsed)
        info
      end
    end
  end
end
