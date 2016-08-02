# name: discourse-ekklesia
# about: provides Ekklesia eDemocracy platform features for Discourse
# version: 0.2.0
# url: https://github.com/edemocracy
# authors: Tobias dpausp <dpausp@posteo.de>

# If you don't allow other login methods (only via Ekklesia ID server), then the sign-up button can be hidden like that:
#
#    .sign-up-button {
#      display: none !important;
#    }
#
# (put this CSS in: Admin Area -> Customize -> CSS/HTML -> your style -> CSS)


# XXX: don't know if disabling works for auth providers, check discourse code
enabled_site_setting :ekklesia_enabled

load File.expand_path('../lib/omniauth-ekklesia.rb', __FILE__)

# add the following line somewhere in the code to open an interactive pry session in the current frame
#require 'pry'; binding.pry

# Discourse OAuth2 authenticator using the Ekklesia omniauth strategy.
# Following environment vars must be set:
# * EKKLESIA_CLIENT_SECRET
# * EKKLESIA_SITE_URL
#
# EKKLESIA_CLIENT_ID defaults to 'discourse' if not set
#
class EkklesiaAuthenticator < ::Auth::Authenticator
  CLIENT_ID = ENV.fetch('EKKLESIA_CLIENT_ID', 'discourse')
  CLIENT_SECRET = ENV.fetch('EKKLESIA_CLIENT_SECRET')
  SITE_URL = ENV.fetch('EKKLESIA_SITE_URL')

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

    #require 'pry'; binding.pry
    result = Auth::Result.new
    result.name = data[:nickname]

    user_id = ::PluginStore.get(name, "auid_#{auid}")

    if user_id
      result.user = User.where(id: user_id).first
      if result.user
        increase_user_trust_level result.user
      end
    end

    result.extra_data = { auid: auid }

    # only for development: supply valid mail adress to skip mail confirmation
    #result.email = 'fake@adress.is'
    #result.email_valid = true
    result
  end

  def increase_user_trust_level(user)
    # increase trust level to level granted by ekklesia auth
    lvl = SiteSetting.ekklesia_auto_trust_level
    user.update_attribute(:trust_level, lvl) if user.trust_level < lvl
  end

  def after_create_account(user, auth)
    auid = auth[:extra_data][:auid]
    ::PluginStore.set(name, "auid_#{auid}", user.id)
    auto_group = Group.where(name: SiteSetting.ekklesia_auto_group).first
    user.groups << auto_group if auto_group
    # XXX: saving the user obj recalculates the password hash. This leads to unintended email token invalidation.
    # remove raw password in user object to avoid recalculation.
    user.instance_variable_set(:@raw_password, nil)
    user.update_attribute(:trust_level, SiteSetting.ekklesia_auto_trust_level)
  end
end

auth_provider(
  title_setting: "ekklesia_login_button_title",
  enabled_setting: "ekklesia_enabled",
  message: 'Log in!',
  frame_width: 920,
  frame_height: 800,
  authenticator: EkklesiaAuthenticator.new
)

register_css <<CSS

.btn-social.ekklesia {
  background: rgb(253, 195, 0);
  color: black;
}

/* try to match the look of a normal link for the password change link which is in the wrong div */

a.change-id-password {
  font-size: inherit !important;
  color: #0088cc !important;
}

.change-id-password i {
  font-size: inherit !important;
  color: inherit !important;
}
CSS


