source 'https://rubygems.org'

ruby '3.2.2'

gem 'bootsnap', :require => false                                     # Reduces boot times through caching; required in config/boot.rb
gem 'countries', '~> 5.7'                                             # Collection of all sorts of useful information for every country in the ISO 3166 standard
gem 'country_select', '~> 8.0', '>= 8.0.3'                            # Provides a simple helper to get an HTML select list of countries
gem 'cssbundling-rails', '~> 1.1'                                     # Use SCSS for stylesheets
gem 'devise', '~> 4.9.2'                                              # Flexible authentication solution for Rails with Warden
gem 'devise-i18n', '~> 1.12', '>= 1.12.1'                             # Translations for the devise gem
gem 'faraday-http-cache', '~> 2.4'                                    # Faraday middleware that respects HTTP cache
gem 'foreman', '~> 0.87.2'                                            # Process manager for applications with multiple components
gem 'github_api', '~> 0.19.0'                                         # GitHub API
gem 'haml', '~> 6.2'                                                  # HTML Abstraction Markup Language - A Markup Haiku
gem 'jbuilder', '~> 2.11', '>= 2.11.5'                                # Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jsbundling-rails', '~> 1.1'                                      # Bundle and transpile JavaScript in Rails with esbuild
gem 'kaminari', '~> 1.2', '>= 1.2.2'                                  # Pagination
gem 'kaminari-i18n', '~> 0.5.0'                                       # Translations for the Kaminari gem
gem 'kramdown', '~> 2.4'                                              # Yet-another-markdown-parser but fast
gem 'mongoid', '~> 8.1', '>= 8.1.3'                                   # The Official Ruby Object Mapper for MongoDB
gem 'omniauth', '~> 2.1', '>= 2.1.1'                                  # Flexible authentication system utilizing Rack middleware
gem 'puma', '>= 5.0'                                                  # Use the Puma web server [https://github.com/puma/puma]
gem 'rails', '~> 7.1'                                                 # Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'redcarpet', '~> 3.6'                                             # The safe Markdown parser, reloaded
gem 'redis', '>= 4.0.1'                                               # Use Redis adapter to run Action Cable in production
gem 'responders', '~> 3.1'                                            # A set of Rails responders to dry up your application
gem 'rubocop', :require => false                                      # A Ruby static code analyzer and formatter
gem 'sanitize', '~> 6.1'                                              # HTML & CSS Sanitizer
gem 'sentry-rails', '~> 5.11'                                         # A gem that provides Rails integration for the Sentry error logger
gem 'shrine', '~> 3.5'                                                # File Attachment toolkit for Ruby applications
gem 'shrine-mongoid', '~> 1.0'                                        # Mongoid integration for Shrine
gem 'sprockets-rails', '~> 3.4', '>= 3.4.2'                           # The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'stimulus-rails', '~> 1.2', '>= 1.2.2'                            # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'turbo-rails', '~> 1.4'                                           # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'tzinfo-data', :platforms => [:windows, :jruby]                   # Windows does not include zoneinfo files, so bundle the tzinfo-data gem

group :development, :test do
  gem 'byebug', '~> 11.1', '>= 11.1.3', :platforms => [               # Call 'byebug' anywhere in the code to stop execution and get a debugger console
    :mri, :mingw, :x64_mingw
  ]
end

group :development do
  gem 'bcrypt_pbkdf', '~> 1.1'                                        # Resolve OpenSSH problems with capistrano
  gem 'capistrano', '~> 3.18', :require => false                      # Deployment
  gem 'capistrano-bundler', '~> 2.1', :require => false               # Capistrano bundler integration
  gem 'capistrano-rails', '~> 1.6', '>= 1.6.3', :require => false     # Ruby on Rails specific tasks for Capistrano
  gem 'ed25519', '~> 1.3'                                             # Resolve OpenSSH problems with capistrano
  gem 'error_highlight', '>= 0.4.0', :platforms => [:ruby]            # Add a short explanation where the exception is raised
  gem 'rack-mini-profiler', '~> 3.1', '>= 3.1.1'                      # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem 'rvm1-capistrano3', '~> 1.4', :require => false                 # Capistrano rvm integration
  gem 'web-console', '~> 4.2', '>= 4.2.1'                             # Use console on exceptions pages [https://github.com/rails/web-console]
end

group :test do
  gem 'capybara', '~> 3.39', '>= 3.39.2'                              # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'factory_bot_rails', '~> 6.2'                                   # Fixtures replacement with a straightforward definition syntax
  gem 'rspec-rails', '~> 6.0', '>= 6.0.3'                             # RSpec for Rails 5+
  gem 'selenium-webdriver'                                            # Adds support for Capybara system testing and selenium driver
  gem 'webdrivers', '~> 5.3'                                          # Keep your Selenium WebDrivers updated automatically
end
