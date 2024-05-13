Clearance.configure do |config|
  config.allow_sign_up = true
  if Rails.env.development?
    config.cookie_domain = 'localhost'
  else
    config.cookie_domain = '.railssass.com'
  end
  config.cookie_expiration = lambda { |cookies| 1.year.from_now.utc }
  config.cookie_name = "_traders_session"
  config.cookie_path = "/"
  config.routes = false
  config.httponly = true
  config.mailer_sender = "jin@railssass.com"
  config.password_strategy = Clearance::PasswordStrategies::BCrypt
  config.redirect_url = "/"
  config.rotate_csrf_on_sign_in = true
  config.same_site = :lax
  config.secure_cookie = Rails.env.production?
  config.signed_cookie = false
  config.sign_in_guards = []
  config.user_model = "User"
  config.parent_controller = "ApplicationController"
  config.sign_in_on_password_reset = false
end
