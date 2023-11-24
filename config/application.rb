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
  SMTP = ENV['MAILER_SMTP']
  URL = 'https://rva.lat'

  CARS_REPO_URL = 'https://cars.rva.lat'
  TRACKS_REPO_URL = 'https://tracks.rva.lat'

  GIT = 'https://github.com/Re-Volt-America'
  GIT_REPO = 'RVA'
  GIT_ISSUES_URL = "#{GIT}/#{GIT_REPO}/issues"

  SPONSOR_URL = 'https://github.com/sponsors/BGMP'
  CROWDIN_URL = 'https://translate.rva.lat/'
  DISCORD_URL = 'https://discord.gg/9SCruDud7N'
end

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

module SYS
  RVA_CATEGORY_NAMES = %w(rookie amateur advanced semi-pro pro super-pro random clockwork)
  RVA_CATEGORY_COLORS = %w(#3c3cff #00af63 #f0e764 #ff7823 #ff2323 #c337ff #6e6e6e #d7d7d7)
  RVGL_CAR_CATEGORY_NAMES = %w(rookie amateur advanced semi-pro pro super-pro clockwork)
  RVGL_TRACK_DIFFICULTY_NAMES = %w(easy medium hard extreme)

  CSV_TYPE = PLATFORM.windows? ? 'application/vnd.ms-excel'.freeze : 'text/csv'.freeze
  XLSM_TYPE = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.freeze

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
    RVA_NUMBERS_MAP = {
      :Rookie => CATEGORY::ROOKIE,
      :Amateur => CATEGORY::AMATEUR,
      :Advanced => CATEGORY::ADVANCED,
      :'Semi-Pro' => CATEGORY::SEMI_PRO,
      :Pro => CATEGORY::PRO,
      :'Super-Pro' => CATEGORY::SUPER_PRO,
      :Random => CATEGORY::RANDOM,
      :Clockwork => CATEGORY::CLOCKWORK
    }
    RVGL_NUMBERS_MAP = {
      :Rookie => CATEGORY::ROOKIE,
      :Amateur => CATEGORY::AMATEUR,
      :Advanced => CATEGORY::ADVANCED,
      :'Semi-Pro' => CATEGORY::SEMI_PRO,
      :Pro => CATEGORY::PRO,
      :'Super-Pro' => CATEGORY::SUPER_PRO,
      :Clockwork => CATEGORY::CLOCKWORK
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

module DISTRIBUTE
  PACKAGES = 'https://distribute.rva.lat/packages.json'
  RVA_CARS = 'https://distribute.rva.lat/rva/rva_cars.zip'
  RVA_TRACKS = 'https://distribute.rva.lat/rva/rva_tracks.zip'
  RVA_POINTS_WIN64 = 'https://distribute.rva.lat/rva_points/win64/rva_points_win64.zip'
  RVA_POINTS_LINUX = 'https://distribute.rva.lat/rva_points/linux/rva_points_linux.zip'
  RVA_MARK = 'https://distribute.rva.lat/assets/rva-mark.zip'
  RVGL_LAUNCHER = 'https://re-volt.gitlab.io/rvgl-launcher/#download'
end

module RVA
  class Application < Rails::Application
    class << self
      def rva_role
        ENV['RVA_ROLE'] || 'rva'
      end

      def rva_role=(role)
        return if role == rva_role

        ENV['RVA_ROLE'] = role
        Rails.application&.reload_routes!
      end
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Gracefully handle website exceptions such as 404, 422 & 500. All through the ErrorsController
    config.exceptions_app = routes

    config.time_zone = 'Central Time (US & Canada)'

    config.eager_load_paths << Rails.root.join('extras')

    config.assets.paths << Rails.root.join('app', 'assets')

    config.hosts << ORG::DOMAIN
    config.hosts << "staging.#{ORG::DOMAIN}"

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
