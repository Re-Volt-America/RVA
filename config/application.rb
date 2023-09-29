require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require "active_record/railtie"
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ORG
  NAME = 'Re-Volt America'
  NAME_SHORT = 'RVA'
  DESCRIPTION = 'The Website for the Re-Volt America Community'
  DOMAIN = 'rva.lat'
  EMAIL = 'support@rva.lat'
  URL = 'https://rva.lat'
  CARS_REPO_URL = 'https://cars.rva.lat'
  TRACKS_REPO_URL = 'https://tracks.rva.lat'
end

module SYS
  RVA_CATEGORY_NAMES = %w(rookie amateur advanced semi-pro pro super-pro random clockwork)
  RVGL_CAR_CATEGORY_NAMES = %w(rookie amateur advanced semi-pro pro super-pro clockwork)
  RVGL_TRACK_DIFFICULTY_NAMES = %w(easy medium hard extreme)
  SESSION_NUMBERS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]

  module CAR
    MYSTERY_NAME = 'Mystery'
    CLOCKWORK_NAME = 'Clockwork'
  end

  module TRACK
    UNKNOWN = -1

    EASY = 0
    MEDIUM = 1
    HARD = 2
    EXTREME = 3

    DIFFICULTIES = {
      :easy => EASY,
      :medium => MEDIUM,
      :hard => HARD,
      :extreme => EXTREME,

      :unknown => UNKNOWN
    }
  end

  module CATEGORY
    ROOKIE = 0
    AMATEUR = 1
    ADVANCED = 2
    SEMI_PRO = 3
    PRO = 4
    SUPER_PRO = 5
    RANDOM = 6
    CLOCKWORK = 7
    NUMBERS_MAP = {
      :rookie => CATEGORY::ROOKIE,
      :amateur => CATEGORY::AMATEUR,
      :advanced => CATEGORY::ADVANCED,
      :'semi-pro' => CATEGORY::SEMI_PRO,
      :pro => CATEGORY::PRO,
      :'super-pro' => CATEGORY::SUPER_PRO,
      :random => CATEGORY::RANDOM,
      :clockwork => CATEGORY::CLOCKWORK
    }
    BONUSES_PER_DIFF = {
      0 => 1.0,
      1 => 1.25,
      2 => 1.5,
      3 => 1.75,
      4 => 2,
      5 => 2.25
    }
  end

  module SCORING
    NORMALIZER_CONSTANT = 0.1
    NORMAL = {
      1 => 15,
      2 => 12,
      3 => 10,
      4 => 7,
      5 => 5,
      6 => 4,
      7 => 2, 8 => 2,
      9 => 1,
      10 => 1, 11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1
    }
    BIG = {
      1 => 20,
      2 => 16,
      3 => 12,
      4 => 10,
      5 => 8, 6 => 8,
      7 => 6,
      8 => 4,
      9 => 2, 10 => 2,
      11 => 1, 12 => 1, 13 => 1, 14 => 1, 15 => 1, 16 => 1
    }
  end
end

module RVA
  module PLATFORM
    def self.windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def self.mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def self.unix?
      !PLATFORM.windows?
    end

    def self.linux?
      PLATFORM.unix? and !PLATFORM.mac?
    end

    def self.jruby?
      RUBY_ENGINE == 'jruby'
    end
  end

  class Application < Rails::Application
    class << self
      def rva_role
        ENV['RVA_ROLE'] || 'rva'
      end

      def rva_role=(role)
        return if role == rva_role

        ENV['RVA_ROLE'] = role
        Rails.application.reload_routes! if Rails.application
      end
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Gracefully handle website exceptions such as 404, 422 & 500. All through the ErrorsController
    config.exceptions_app = routes

    config.time_zone = 'Central Time (US & Canada)'

    config.eager_load_paths << Rails.root.join('extras')

    config.assets.paths << Rails.root.join('app', 'assets')

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
