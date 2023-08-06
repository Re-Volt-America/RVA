source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.3'

gem 'bootsnap', '>= 1.4.4', :require => false     # Reduces boot times through caching; required in config/boot.rb
gem 'cssbundling-rails', '~> 1.1'                 # Use SCSS for stylesheets
gem 'devise', '~> 4.9'                            # Flexible authentication solution for Rails with Warden
gem 'haml', '~> 6.1', '>= 6.1.1'                  # HTML Abstraction Markup Language - A Markup Haiku
gem 'jbuilder', '~> 2.7'                          # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jsbundling-rails', '~> 1.1'                  # Bundle and transpile JavaScript in Rails with esbuild
gem 'kaminari', '~> 1.2.1'                        # Pagination
gem 'kaminari-i18n', '~> 0.5.0'                   # Translations for the Kaminari gem
gem 'mongoid', '~> 8.0', '>= 8.0.3'               # The Official Ruby Object Mapper for MongoDB
gem 'omniauth', '~> 2.1', '>= 2.1.1'              # Flexible authentication system utilizing Rack middleware
gem 'puma', '~> 5.0'                              # Use Puma as the app server
gem 'rails', '~> 6.1.4', '>= 6.1.4.1'             # Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'redcarpet', '~> 3.6'                         # The safe Markdown parser, reloaded
gem 'redis', '~> 4.0'                             # Use Redis adapter to run Action Cable in production
gem 'responders', '~> 3.1'                        # A set of Rails responders to dry up your application
gem 'rubocop', :require => false                  # A Ruby static code analyzer and formatter
gem 'sentry-ruby', '~> 5.8'                       # Sentry SDK for Ruby
gem 'stimulus-rails', '~> 1.2', '>= 1.2.1'        # Use Stimulus in your Ruby on Rails app
gem 'turbo-rails', '~> 1.3', '>= 1.3.3'           # Use Turbo in your Ruby on Rails app

# Fix protocol warnings...
gem 'net-http', :require => false
gem 'net-imap', :require => false
gem 'net-protocol', :require => false
gem 'net-smtp', :require => false

group :development, :test do
  gem 'byebug', :platforms => [                   # Call 'byebug' anywhere in the code to stop execution and get a debugger console
    :mri, :mingw, :x64_mingw
  ]
  gem 'erb2haml', '~> 0.1.5'                      # Bulk covert ERB to HAML
end

group :development do
  gem 'rack-mini-profiler', '~> 2.0'              # Display performance information such as SQL time and flame graphs for each request in your browser.
  gem 'web-console', '>= 4.1.0'                   # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'factory_bot_rails', '~> 6.2'               # Fixtures replacement with a straightforward definition syntax
  gem 'rspec-rails', '~> 6.0', '>= 6.0.1'         # RSpec for Rails 5+
  gem 'selenium-webdriver', '>= 4.0.0.rc1'        # Adds support for Capybara system testing and selenium driver
  gem 'webdrivers'                                # Easy installation and use of web drivers to run system tests with browsers
end

gem 'tzinfo-data', :platforms => [                # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
  :mingw, :mswin, :x64_mingw, :jruby, :ruby
]
