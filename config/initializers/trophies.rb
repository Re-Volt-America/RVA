# frozen_string_literal: true

# =============================================================================
#  TROPHY DEFINITIONS  (admins: this is the file you edit)
# =============================================================================
#
# Every trophy players can earn on the site is declared here. Adding a new one
# is two steps:
#
#   1. Add a `Trophy.define ...` line below.
#   2. Add its name + description under `users.trophies.items.<key>` in
#      config/locales/en.yml (and translate via Crowdin as usual).
#
# Two ways to express the "how do you earn it?" condition:
#
#   * Declarative threshold against a Stats field (race_wins, session_wins,
#     session_podiums, race_podiums, session_count, ...):
#
#         Trophy.define :session_wins_10,
#                       :icon => 'fa-medal', :tier => :silver,
#                       :stat => :session_wins, :at_least => 10
#
#   * A block for anything more specific. It receives a TrophyContext (see
#     app/services/trophy_context.rb) exposing helpers such as
#     won_session_with_car?, won_race_at_track?, won_ranking?, session_win_count.
#     Add more helpers there as you invent new kinds of trophies.
#
#         Trophy.define :raton_altista, :icon => 'fa-mouse', :tier => :gold do |ctx|
#           ctx.won_session_with_car?('Mouse')
#         end
#
# Icons are Font Awesome 5 classes (the site loads FA 5.13), e.g. 'fa-trophy'.
# Tiers (:bronze, :silver, :gold, :platinum) only affect the card's accent color.
#
# Definitions are (re)loaded on every code reload via to_prepare, so changes
# here show up without a full restart in development.
# =============================================================================

Rails.application.config.to_prepare do
  Trophy.reset!

  # -- "Win X sessions" family (declarative thresholds) -----------------------

  Trophy.define :first_win,
                :icon => 'fa-flag-checkered', :tier => :bronze,
                :stat => :session_wins, :at_least => 1

  Trophy.define :session_wins_10,
                :icon => 'fa-medal', :tier => :silver,
                :stat => :session_wins, :at_least => 10

  Trophy.define :session_wins_100,
                :icon => 'fa-crown', :tier => :gold,
                :stat => :session_wins, :at_least => 100

  # -- Podium regularity ------------------------------------------------------

  Trophy.define :podium_regular,
                :icon => 'fa-award', :tier => :silver,
                :stat => :session_podiums, :at_least => 25

  # -- Custom-logic trophies --------------------------------------------------

  # Win a session driving the "Mouse".
  Trophy.define :raton_altista, :icon => 'fa-cheese', :tier => :gold do |ctx|
    ctx.won_session_with_car?('Mouse')
  end

  # Finish 1st in a concluded ranking.
  Trophy.define :ranking_champion, :icon => 'fa-trophy', :tier => :platinum do |ctx|
    ctx.won_ranking?
  end
end
