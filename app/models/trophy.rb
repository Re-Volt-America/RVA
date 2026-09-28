# frozen_string_literal: true

# A Trophy is an achievement players can earn by meeting some criteria on the
# site (e.g. winning a number of sessions, winning with a particular car, etc.).
#
# Trophies are NOT stored in the database. They are defined in code by admins,
# which keeps their names/descriptions translatable (they resolve to I18n keys,
# so Crowdin picks them up) and keeps the whole feature version-controlled.
#
# Add or edit trophies in `config/initializers/trophies.rb`.
#
# Each definition needs:
#   * a unique key (Symbol)         -> used for storage and for the I18n lookup
#   * an :icon (Font Awesome class) -> shown on the trophy card, e.g. "fa-medal"
#   * an optional :tier             -> :bronze (default), :silver, :gold, :platinum
#   * a condition, expressed either declaratively or as a block:
#       - declarative threshold against a Stats field:
#           Trophy.define :session_wins_10, icon: "fa-medal", stat: :session_wins, at_least: 10
#       - custom logic via a block that receives a TrophyContext:
#           Trophy.define :raton_altista, icon: "fa-cheese" do |ctx|
#             ctx.won_session_with_car?("Mouse")
#           end
#
# The name and description are looked up at render time from:
#   users.trophies.items.<key>.name
#   users.trophies.items.<key>.description
class Trophy
  # Ordered so lower tiers render/sort before higher ones.
  TIERS = %i[bronze silver gold platinum].freeze

  # The in-memory registry of every defined trophy, keyed by its Symbol key.
  # Repopulated on every code reload via `config.to_prepare` (see the initializer).
  @registry = {}

  class << self
    attr_reader :registry

    # Define (or redefine) a trophy. See the class docs for the accepted options.
    #
    # @param key [Symbol, String] unique identifier for the trophy
    # @param icon [String] a Font Awesome icon class, e.g. "fa-trophy"
    # @param tier [Symbol] one of TIERS
    # @param stat [Symbol, nil] a Stats field name for the declarative threshold form
    # @param at_least [Numeric, nil] the minimum value of `stat` required to earn it
    # @yield [TrophyContext] optional block returning a truthy value when earned
    # @return [Trophy]
    def define(key, icon:, tier: :bronze, stat: nil, at_least: nil, &block)
      key = key.to_sym

      unless TIERS.include?(tier)
        raise ArgumentError, "Trophy #{key}: unknown tier #{tier.inspect} (expected one of #{TIERS.inspect})"
      end

      condition =
        if block_given?
          block
        elsif stat && at_least
          field = stat.to_sym
          minimum = at_least
          ->(ctx) { (ctx.stat(field) || 0) >= minimum }
        else
          raise ArgumentError, "Trophy #{key}: provide either a block or both stat: and at_least:"
        end

      @registry[key] = new(key, icon, tier, condition)
    end

    # @return [Array<Trophy>] every defined trophy
    def all
      @registry.values
    end

    # @return [Trophy, nil]
    def find(key)
      return nil if key.nil?

      @registry[key.to_sym]
    end

    def exists?(key)
      @registry.key?(key.to_sym)
    end

    # Wipes the registry. Called before re-loading definitions so a code reload
    # in development doesn't leave stale/duplicate trophies around.
    def reset!
      @registry = {}
    end
  end

  attr_reader :key, :icon, :tier, :condition

  def initialize(key, icon, tier, condition)
    @key = key
    @icon = icon
    @tier = tier
    @condition = condition
  end

  # Evaluate whether the given context satisfies this trophy's condition.
  # @param context [TrophyContext]
  def earned_by?(context)
    !!@condition.call(context)
  end

  # Translated, human-readable name. Falls back to a humanized key.
  def name
    I18n.t("users.trophies.items.#{key}.name", :default => key.to_s.humanize)
  end

  # Translated description (used for tooltips). Falls back to an empty string.
  def description
    I18n.t("users.trophies.items.#{key}.description", :default => '')
  end

  def tier_index
    TIERS.index(tier) || 0
  end
end
