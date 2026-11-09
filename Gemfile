source 'https://rubygems.org'

ruby '3.4.12'

gem 'bootsnap', :require => false                                     # Reduces boot times through caching; required in config/boot.rb
gem 'chartkick', '~> 5.1', '>= 5.1.2'                                 # Create beautiful JavaScript charts with one line of Ruby
gem 'connection_pool', '~> 2.5'                                       # Generic connection pool for Ruby
gem 'countries', '~> 5.7'                                             # Collection of all sorts of useful information for every country in the ISO 3166 standard
gem 'country_select', '~> 8.0', '>= 8.0.3'                            # Provides a simple helper to get an HTML select list of countries
gem 'cssbundling-rails', '~> 1.1'                                     # Use SCSS for stylesheets
gem 'csv', '~> 3.3'                                                   # CSV parsing for session/car/track/user imports; no longer a default gem since Ruby 3.4
gem 'devise', '~> 4.9.2'                                              # Flexible authentication solution for Rails with Warden
gem 'devise-i18n', '~> 1.12', '>= 1.12.1'                             # Translations for the devise gem
gem 'faraday', '<= 2'                                                 # HTTP/REST API client library.
gem 'faraday-http-cache', '~> 2.4'                                    # Faraday middleware that respects HTTP cache
gem 'foreman', '~> 0.87.2'                                            # Process manager for applications with multiple components
gem 'github_api', '~> 0.19.0'                                         # GitHub API
gem 'groupdate', '~> 6.5', '>= 6.5.1'                                 # The simplest way to group temporal data
gem 'haml', '~> 6.2'                                                  # HTML Abstraction Markup Language - A Markup Haiku
gem 'jbuilder', '~> 2.11', '>= 2.11.5'                                # Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jsbundling-rails', '~> 1.1'                                      # Bundle and transpile JavaScript in Rails with esbuild
gem 'kaminari', '~> 1.2', '>= 1.2.2'                                  # Pagination
gem 'kaminari-i18n', '~> 0.5.0'                                       # Translations for the Kaminari gem
gem 'kramdown', '~> 2.4'                                              # Yet-another-markdown-parser but fast
gem 'mongo', '~> 2.26'                                                # MongoDB Ruby driver (used by Mongoid); 2.22+ is tested on Ruby 3.4
gem 'mongoid', '~> 8.1', '>= 8.1.3'                                   # The Official Ruby Object Mapper for MongoDB
gem 'net-imap', '>= 0.4.24'                                           # Ruby client api for Internet Message Access Protocol
gem 'omniauth', '~> 2.2'                                            # Flexible authentication system utilizing Rack middleware
gem 'puma', '>= 5.0'                                                  # Use the Puma web server [https://github.com/puma/puma]
gem 'rack-attack', '~> 6.7'                                           # A rack middleware for throttling and blocking abusive requests
gem 'rack-cors', '~> 2.0', '>= 2.0.2'                                 # Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem 'rails', '~> 7.2.3', '>= 7.2.3.2'                                 # Rails!
gem 'recaptcha', '~> 5.18'                                            # Helpers for the reCAPTCHA API
gem 'redcarpet', '~> 3.6'                                             # The safe Markdown parser, reloaded
gem 'redis', '>= 4.0.1'                                               # Use Redis adapter to run Action Cable in production
gem 'responders', '~> 3.1'                                            # A set of Rails responders to dry up your application
gem 'rubocop', :require => false                                      # A Ruby static code analyzer and formatter
gem 'sanitize', '~> 6.1'                                              # HTML & CSS Sanitizer
gem 'sentry-rails', '~> 5.11'                                         # A gem that provides Rails integration for the Sentry error logger
gem 'shrine', '~> 3.5'                                                # File Attachment toolkit for Ruby applications
gem 'shrine-mongoid', '~> 1.0'                                        # Mongoid integration for Shrine
gem 'sidekiq', '~> 7.3'                                               # Simple, efficient background processing for Ruby (backed by Redis)
gem 'sidekiq-cron', '~> 1.12'                                         # Cron scheduler for Sidekiq
gem 'sprockets-rails', '~> 3.4', '>= 3.4.2'                           # The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'stimulus-rails', '~> 1.2', '>= 1.2.2'                            # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'turbo-rails', '~> 1.4'                                           # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'tzinfo-data', :platforms => [:windows, :jruby]                   # Windows does not include zoneinfo files, so bundle the tzinfo-data gem

group :development, :test do
  gem 'debug', '>= 1.11.1', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'awesome_print', '~> 1.9', '>= 1.9.2'                           # Print Ruby objects to visualize their structure
  gem 'bcrypt_pbkdf', '>= 1.1.2'                                      # Resolve OpenSSH problems with capistrano
  gem 'capistrano', '~> 3.20', :require => false                      # Deployment
  gem 'ed25519', '>= 1.4'                                             # Resolve OpenSSH problems with capistrano
  gem 'net-ssh', '~> 7.3'                                             # SSH for capistrano; 7.2.1+ handles Socket#recv returning nil on Ruby 3.3+
  gem 'rack-mini-profiler', '>= 4.0.1'                                # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem 'sshkit', '~> 1.25'                                             # Capistrano SSH toolkit; <1.22 requires mutex_m, which is no longer a default gem since Ruby 3.4
  gem 'web-console', '~> 4.2', '>= 4.2.1'                             # Use console on exceptions pages [https://github.com/rails/web-console]
end

group :test do
  gem 'capybara', '~> 3.39', '>= 3.39.2'                              # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'factory_bot_rails', '~> 6.2'                                   # Fixtures replacement with a straightforward definition syntax
  gem 'rspec-rails', '~> 6.0', '>= 6.0.3'                             # RSpec for Rails 5+
  gem 'selenium-webdriver', '~> 4.10.0'                               # Adds support for Capybara system testing and selenium driver
  gem 'webdrivers', '~> 5.3'                                          # Keep your Selenium WebDrivers updated automatically
end
