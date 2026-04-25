Recaptcha.configure do |config|
  config.site_key   = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
  config.skip_verify_env.push('development', 'test', 'staging')
end
