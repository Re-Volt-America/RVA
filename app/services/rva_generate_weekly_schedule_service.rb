class RvaGenerateWeeklyScheduleService
  include ApplicationHelper
  include SeasonsHelper

  def initialize(weekly_schedule_params)
    @season = Season.find(weekly_schedule_params[:season])
    @start_date = weekly_schedule_params[:start_date]
  end

  def generate
    category_numbers = [
      SYS::CATEGORY::ROOKIE,
      SYS::CATEGORY::AMATEUR,
      SYS::CATEGORY::ADVANCED,
      SYS::CATEGORY::SEMI_PRO,
      SYS::CATEGORY::PRO,
      SYS::CATEGORY::SUPER_PRO,
      SYS::CATEGORY::RANDOM
    ].shuffle

    season_tracks = @season.tracks.clone

    track_lists = {}
    num_track_lists = 0
    category_numbers.each do |n|
      if season_tracks.length < 20
        season_tracks = @season.tracks.clone
      end

      # pick 20 random tracks for each TrackList
      track_list_entries = {}
      num_track_list_entries = 0
      season_tracks = season_tracks.shuffle

      20.times do
        track = season_tracks.pop.clone

        track_entry_hash = {
          :name => track.name,
          :stock => track.stock,
          :lap_count => track.lap_count(n)
        }

        track_list_entries = track_list_entries.merge(num_track_list_entries.to_s => track_entry_hash)

        num_track_list_entries += 1
      end

      track_list_hash = {
        :category => n,
        :track_count => 20,
        :track_list_entries => track_list_entries
      }

      track_lists = track_lists.merge(num_track_lists.to_s => track_list_hash)

      num_track_lists += 1
    end

    weekly_schedule_hash = {
      :season => @season,
      :start_date => @start_date,
      :track_lists => track_lists
    }

    WeeklySchedule.new(weekly_schedule_hash)
  end
end
