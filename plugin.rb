# name: discourse-ekklesia
# about: integration with the Ekklesia eDemocracy platform (https://github.com/edemocracy/ekklesia) (currently oauth, more to come)
# version: 0.0.0
# authors: Tobias dpausp <dpausp@posteo.de>

require 'auth/oauth2_authenticator'
require 'omniauth-oauth2'


class OmniAuth::Strategies::Ekklesia < OmniAuth::Strategies::OAuth2

  # TODO: make this configurable
  SITE_URL = '<beoauth_server>'

  option :name, "ekklesia"

  option :client_options, {
        :site => SITE_URL,
        :authorize_url => SITE_URL + '/oauth2/authorize/',
        :token_url => SITE_URL + '/oauth2/token/',
  }

  uid { raw_info['auid'] }

  info do
    {
      :nickname => raw_info['username'],
    }
  end

  extra do
    {
      'raw_info' => raw_info
    }
  end

  def raw_info
    info = access_token.get('/api/v1/user/auid/').parsed
    info.merge!(access_token.get('/api/v1/user/profile/').parsed)
    info.merge!(access_token.get('/api/v1/user/membership/').parsed)
    info
  end
end

### register authenticator with discourse

class EkklesiaAuthenticator < ::Auth::OAuth2Authenticator

  # TODO: make this configurable
  CLIENT_ID = '<client id>'
  CLIENT_SECRET = '<client secret>'

  def register_middleware(omniauth)
    omniauth.provider :ekklesia,
      CLIENT_ID,
      CLIENT_SECRET
  end

  def name
    'ekklesia'
  end

  def initialize(opts={})
    @opts = opts
  end

  def after_authenticate(auth_token)

    data = auth_token[:info]
    auid = auth_token[:uid]

    result = Auth::Result.new
    result.name = data[:nickname]

    user_id = ::PluginStore.get(self.name, "auid_#{auid}")

    if user_id
      result.user = User.where(id: user_id).first
    end
    
    result.extra_data = {
      auid: auid
    }

    # only for development: supply valid mail adress to skip mail confirmation
    #result.email = 'fake@adress.is'
    #result.email_valid = true
    result
  end

  def after_create_account(user, auth)
    auid = auth[:extra_data][:auid]
    ::PluginStore.set(self.name, "auid_#{auid}", user.id)
    # TODO: make this configurable
    user.change_trust_level! 3
    # TODO: make group name configurable
    auto_group = Group.where(:name => '<group name>').first
    user.groups << auto_group
  end
end

# TODO: make login title configurable
auth_provider :title => 'with Ekklesia',
    :message => 'Log in!',
    :frame_width => 920,
    :frame_height => 800,
    :authenticator => EkklesiaAuthenticator.new

register_css <<CSS

.btn-social.ekklesia {
  background: #dd4814;
}

CSS
