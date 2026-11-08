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
#         Trophy.define :contender,
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

  Trophy.define :first_win,
                :icon => 'fa-flag-checkered', :tier => :bronze,
                :stat => :session_wins, :at_least => 1

  Trophy.define :contender,
                :icon => 'fa-medal', :tier => :silver,
                :stat => :session_wins, :at_least => 25

  Trophy.define :centurion,
                :icon => 'fa-crown', :tier => :gold,
                :stat => :session_wins, :at_least => 500

  Trophy.define :podium_regular,
                :icon => 'fa-award', :tier => :silver,
                :stat => :session_podiums, :at_least => 75

  Trophy.define :podium_fixture,
                :icon => 'fa-certificate', :tier => :gold,
                :stat => :session_podiums, :at_least => 200

  Trophy.define :veteran,
                :icon => 'fa-hourglass-half', :tier => :silver,
                :stat => :session_count, :at_least => 200

  Trophy.define :getting_started,
                :icon => 'fa-car-side', :tier => :bronze,
                :stat => :race_count, :at_least => 500

  Trophy.define :road_warrior,
                :icon => 'fa-road', :tier => :gold,
                :stat => :race_count, :at_least => 10000

  Trophy.define :race_winner,
                :icon => 'fa-bolt', :tier => :gold,
                :stat => :race_wins, :at_least => 500

  Trophy.define :speed_demon,
                :icon => 'fa-fire', :tier => :platinum,
                :stat => :race_wins, :at_least => 1000

  Trophy.define :one_big_leap,
                :icon => 'fa-rocket', :tier => :platinum,
                :stat => :race_wins, :at_least => 100000

  Trophy.define :point_hoarder,
                :icon => 'fa-coins', :tier => :gold,
                :stat => :obtained_points, :at_least => 100000

  Trophy.define :perfectionist, :icon => 'fa-star', :tier => :gold do |ctx|
    ctx.perfect_session?
  end

  Trophy.define :sharpshooter, :icon => 'fa-bullseye', :tier => :platinum do |ctx|
    (ctx.stat(:session_count) || 0) >= 20 && (ctx.stat(:session_win_rate) || 0) >= 0.5
  end

  Trophy.define :hat_trick, :icon => 'fa-hat-wizard', :tier => :gold do |ctx|
    ctx.max_consecutive_session_wins >= 3
  end

  Trophy.define :raton_altista, :icon => 'fa-mouse', :tier => :gold do |ctx|
    ctx.won_session_with_car?('Mouse')
  end

  Trophy.define :spray_em_all, :icon => 'fa-spray-can', :tier => :gold do |ctx|
    ctx.won_session_with_car?('Pest Control')
  end

  Trophy.define :car_collector, :icon => 'fa-warehouse', :tier => :silver do |ctx|
    ctx.distinct_cars_driven_count >= 50
  end

  Trophy.define :jack_of_all_cars, :icon => 'fa-random', :tier => :gold do |ctx|
    ctx.distinct_cars_in_won_sessions_count >= 15
  end

  Trophy.define :mr_worldwide, :icon => 'fa-globe', :tier => :gold do |ctx|
    ctx.distinct_tracks_won_count >= 50
  end

  Trophy.define :living_legend, :icon => 'fa-calendar-check', :tier => :platinum do |ctx|
    ctx.participated_in_all_seasons?
  end

  Trophy.define :giant_slayer, :icon => 'fa-dragon', :tier => :gold do |ctx|
    ctx.beat_top_player_with_lesser_car?(5)
  end

  Trophy.define :going_nuclear, :icon => 'fa-radiation', :tier => :gold do |ctx|
    ctx.beat_user_in_session?('NUC')
  end

  Trophy.define :beat_the_admin, :icon => 'fa-user-shield', :tier => :gold do |ctx|
    ctx.beat_user_in_session?('BGM')
  end

  Trophy.define :enduro, :icon => 'fa-stopwatch', :tier => :bronze do |ctx|
    ctx.finished_long_race?(15)
  end

  Trophy.define :lanterne_rouge, :icon => 'fa-poop', :tier => :bronze do |ctx|
    ctx.finished_last_in_a_race?
  end

  Trophy.define :ranking_champion, :icon => 'fa-trophy', :tier => :platinum do |ctx|
    ctx.won_ranking?
  end

  # -- Manual trophies (granted by an admin only, never auto-awarded) ----------

  Trophy.define :official_business, :icon => 'fa-user-md', :tier => :gold, :manual => true
  Trophy.define :translator, :icon => 'fa-globe-americas', :tier => :gold, :manual => true


  # One trophy per season, named after the season itself, for taking part in it.
  # Generated from the database so every new season automatically gets its own
  # trophy. Guarded: if the DB is unreachable at load time (e.g. asset
  # precompile) we simply skip them rather than break boot.
  begin
    Season.order_by(:start_date => :asc).each do |season|
      Trophy.define :"season_#{season.id}",
                    :icon => 'fa-calendar-day', :tier => :bronze,
                    :name => season.name,
                    :description => -> { I18n.t('users.trophies.season-participant', :name => season.name) } do |ctx|
        ctx.participated_in_season?(season)
      end
    end
  rescue StandardError => e
    Rails.logger.warn("[trophies] skipped per-season trophies: #{e.class}: #{e.message}")
  end

end
