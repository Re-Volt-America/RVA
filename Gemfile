source "https://rubygems.org"

ruby '3.2.2'

gem 'bootsnap', require: false                                        # Reduces boot times through caching; required in config/boot.rb
gem 'devise', '~> 4.9.2'                                              # Flexible authentication solution for Rails with Warden
gem 'haml', '~> 6.2'                                                  # HTML Abstraction Markup Language - A Markup Haiku
gem 'jbuilder', '~> 2.11', '>= 2.11.5'                                # Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'kaminari', '~> 1.2', '>= 1.2.2'                                  # Pagination
gem 'kaminari-i18n', '~> 0.5.0'                                       # Translations for the Kaminari gem
gem 'mongoid', '~> 8.1', '>= 8.1.2'                                   # The Official Ruby Object Mapper for MongoDB
gem 'omniauth', '~> 2.1', '>= 2.1.1'                                  # Flexible authentication system utilizing Rack middleware
gem 'rails', '~> 7.1.0.rc1'                                           # Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'redcarpet', '~> 3.6'                                             # The safe Markdown parser, reloaded
gem "redis", ">= 4.0.1"                                               # Use Redis adapter to run Action Cable in production
gem 'responders', '~> 3.1'                                            # A set of Rails responders to dry up your application
gem 'rubocop', :require => false                                      # A Ruby static code analyzer and formatter
gem 'sprockets-rails', '~> 3.4', '>= 3.4.2'                           # The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'puma', '>= 5.0'                                                  # Use the Puma web server [https://github.com/puma/puma]
gem 'importmap-rails', '~> 1.2', '>= 1.2.1'                           # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'turbo-rails', '~> 1.4'                                           # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'sentry-rails', '~> 5.11'                                         # A gem that provides Rails integration for the Sentry error logger
gem 'stimulus-rails', '~> 1.2', '>= 1.2.2'                            # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]

group :development, :test do
  gem 'byebug', :platforms => [                                       # Call 'byebug' anywhere in the code to stop execution and get a debugger console
    :mri, :mingw, :x64_mingw
  ]
  gem 'erb2haml', '~> 0.1.5'                                          # Bulk covert ERB to HAML
end

group :development do
  gem 'web-console', '~> 4.2', '>= 4.2.1'                             # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'rack-mini-profiler', '~> 3.1', '>= 3.1.1'                      # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem 'error_highlight', ">= 0.4.0", platforms: [:ruby]               # Add a short explanation where the exception is raised
end

group :test do
  gem 'capybara', '~> 3.39', '>= 3.39.2'                              # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'factory_bot_rails', '~> 6.2'                                   # Fixtures replacement with a straightforward definition syntax
  gem 'rspec-rails', '~> 6.0', '>= 6.0.3'                             # RSpec for Rails 5+
  gem 'selenium-webdriver'                                            # Adds support for Capybara system testing and selenium driver
  gem 'webdrivers', '~> 5.3'                                          # Easy installation and use of web drivers to run system tests with
end

gem 'tzinfo-data', platforms: %i[ windows jruby ]                     # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
