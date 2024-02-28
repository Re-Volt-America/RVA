namespace :users do
  desc "Set all users' locales to the default app locale"
  task reset_locales: :environment do
    User.each do |u|
      u.locale = I18n.default_locale
      u.update!
    end
  end
end
