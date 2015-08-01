# name: discourse-ekklesia
# about: integration with the Ekklesia eDemocracy platform (https://github.com/edemocracy/ekklesia) (currently oauth, more to come)
# version: 0.0.0
# authors: Tobias dpausp <dpausp@posteo.de>

require 'auth/oauth2_authenticator'
require 'omniauth-oauth2'


# XXX: don't know if / how disabling works for auth providers, check discourse code 
#enabled_site_setting :ekklesia_oauth_enabled


class OmniAuth::Strategies::Ekklesia < OmniAuth::Strategies::OAuth2

  option :name, "ekklesia"

  option :client_options, {
        :authorize_url => '/oauth2/authorize/',
        :token_url => '/oauth2/token/',
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

  CLIENT_ID = ENV["EKKLESIA_CLIENT_ID"]
  CLIENT_SECRET = ENV["EKKLESIA_CLIENT_SECRET"]
  SITE_URL = ENV["EKKLESIA_SITE_URL"]

  def register_middleware(omniauth)
    Rails.logger.info("registering ekklesia authenticator for #{SITE_URL} , client_id #{CLIENT_ID}")
    omniauth.provider :ekklesia,
      CLIENT_ID,
      CLIENT_SECRET,
      client_options: { site: SITE_URL }
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
    ::PluginStore.set(name, "auid_#{auid}", user.id)
    user.change_trust_level! SiteSetting.ekklesia_auto_trust_level
    auto_group = Group.where(:name => SiteSetting.ekklesia_auto_group).first
    user.groups << auto_group
  end
end


# TODO: login title i18n
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
