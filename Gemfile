source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.3'

gem 'rails', '~> 6.1.6', '>= 6.1.6.1'            # Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'puma', '~> 5.0'                             # Use Puma as the app server
gem 'sass-rails', '>= 6'                         # Use SCSS for stylesheets
gem 'webpacker', '~> 5.0'                        # Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'turbolinks', '~> 5'                         # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'jbuilder', '~> 2.7'                         # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'redis', '~> 4.0'                          # Use Redis adapter to run Action Cable in production
# gem 'bcrypt', '~> 3.1.7'                       # Use Active Model has_secure_password
# gem 'image_processing', '~> 1.2'               # Use Active Storage variant
gem 'bootsnap', '>= 1.4.4', require: false       # Reduces boot times through caching; required in config/boot.rb
gem 'mongoid', '~> 8.0', '>= 8.0.3'
gem 'haml', '~> 6.1', '>= 6.1.1'
gem 'devise', '~> 4.8', '>= 4.8.1'
gem 'omniauth', '~> 2.1', '>= 2.1.1'
gem 'kaminari', '~> 1.2.1'                       # Pagination
gem 'kaminari-i18n', '~> 0.5.0'
gem 'redcarpet', '~> 3.6'
gem 'sentry-ruby', '~> 5.8'
gem 'sentry-rails', '~> 5.8'

# Fix protocol warnings...
gem 'net-http', require: false
gem 'net-imap', require: false
gem 'net-protocol', require: false
gem 'net-smtp', require: false

group :development, :test do
  gem 'byebug', platforms: [                     # Call 'byebug' anywhere in the code to stop execution and get a debugger console
      :mri, :mingw, :x64_mingw
  ]
  gem 'erb2haml', '~> 0.1.5'                     # Bulk covert ERB to HAML
end

group :development do
  gem 'web-console', '>= 4.1.0'                  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'rack-mini-profiler', '~> 2.0'             # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'       # Adds support for Capybara system testing and selenium driver
  gem 'webdrivers'                               # Easy installation and use of web drivers to run system tests with browsers
  gem 'rspec-rails', '~> 6.0', '>= 6.0.1'
  gem 'factory_bot_rails', '~> 6.2'
end

gem 'tzinfo-data', platforms: [                  # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
    :mingw, :mswin, :x64_mingw, :jruby
]
