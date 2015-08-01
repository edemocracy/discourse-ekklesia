# name: discourse-ekklesia
# about: integration with the Ekklesia eDemocracy platform (https://github.com/edemocracy/ekklesia)
# version: 0.0.0
# authors: Tobias dpausp <dpausp@posteo.de>

# XXX: don't know if disabling works for auth providers, check discourse code
# enabled_site_setting :ekklesia_oauth_enabled

load File.expand_path('../lib/omniauth-ekklesia.rb', __FILE__)

# Discourse OAuth2 authenticator using the Ekklesia omniauth strategy.
# Following environment vars must be set:
# * EKKLESIA_CLIENT_SECRET
# * EKKLESIA_SITE_URL
#
# EKKLESIA_CLIENT_ID defaults to 'discourse' if not set
#
class EkklesiaAuthenticator < ::Auth::OAuth2Authenticator
  CLIENT_ID = ENV.fetch('EKKLESIA_CLIENT_ID', 'discourse')
  CLIENT_SECRET = ENV['EKKLESIA_CLIENT_SECRET']
  SITE_URL = ENV['EKKLESIA_SITE_URL']

  def register_middleware(omniauth)
    omniauth.provider(
      :ekklesia,
      CLIENT_ID,
      CLIENT_SECRET,
      client_options: { site: SITE_URL }
    )
    Rails.logger.info("registered ekklesia authenticator for #{SITE_URL} ,"\
      "client_id #{CLIENT_ID}")
  end

  def name
    'ekklesia'
  end

  def initialize(opts = {})
    @opts = opts
  end

  def after_authenticate(auth_token)
    data = auth_token[:info]
    auid = auth_token[:uid]

    result = Auth::Result.new
    result.name = data[:nickname]

    user_id = ::PluginStore.get(name, "auid_#{auid}")

    result.user = User.where(id: user_id).first if user_id

    result.extra_data = {
      auid: auid
    }

    # only for development: supply valid mail adress to skip mail confirmation
    # result.email = 'fake@adress.is'
    # result.email_valid = true
    result
  end

  def after_create_account(user, auth)
    auid = auth[:extra_data][:auid]
    ::PluginStore.set(name, "auid_#{auid}", user.id)
    user.change_trust_level! SiteSetting.ekklesia_auto_trust_level
    auto_group = Group.where(name: SiteSetting.ekklesia_auto_group).first
    user.groups << auto_group
  end
end

# TODO: login title i18n
auth_provider(
  title: 'with Ekklesia',
  message: 'Log in!',
  frame_width: 920,
  frame_height: 800,
  authenticator: EkklesiaAuthenticator.new
)

register_css <<CSS

.btn-social.ekklesia {
  background: #dd4814;
}

CSS
