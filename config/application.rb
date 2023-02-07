require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ORG
  NAME = "Re-Volt America"
  NAME_SHORT = "RVA"
  DESCRIPTION = "The Website for the Re-Volt America Community"
  DOMAIN = "rva.lat"
  EMAIL = "support@rva.lat"
  URL = "https://rva.lat"
end

module RVA
  class Application < Rails::Application
    class << self
      def rva_role
        ENV['RVA_ROLE'] || 'rva'
      end

      def rva_role=(role)
        unless role == rva_role
          ENV['RVA_ROLE'] = role
          Rails.application.reload_routes! if Rails.application
        end
      end
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Gracefully handle website exceptions such as 404, 422 & 500. All through the ErrorsController
    config.exceptions_app = routes

    config.time_zone = "Central Time (US & Canada)"

    config.eager_load_paths << Rails.root.join("extras")

    config.assets.paths << Rails.root.join("app", "assets")

    config.generators.system_tests = nil
    config.generators do |g|
      g.test_framework(
          :rspec,
          :fixtures => false,
          :view_specs => false,
          :helper_specs => false,
          :routing_specs => false
      )
    end
  end
end
