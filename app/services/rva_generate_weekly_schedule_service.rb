class RvaGenerateWeeklyScheduleService
  include ApplicationHelper
  include SeasonsHelper

  def initialize(weekly_schedule_params)
    @season = Season.find(weekly_schedule_params[:season])
    @start_date = weekly_schedule_params[:start_date]
  end

  def generate
    category_numbers = [0, 1, 2, 3, 4, 5, 6].shuffle

    season_tracks = @season.tracks.clone

    track_lists = {}
    num_track_lists = 0
    category_numbers.each do |n|
      if season_tracks.length < 20
        season_tracks = @season.tracks.clone
      end

      # pick 20 random tracks for each TrackList
      tracks = {}
      num_tracks = 0
      season_tracks.shuffle

      20.times do
        track = season_tracks.pop.clone
        tracks = tracks.merge(num_tracks.to_s => track.attributes)

        num_tracks += 1
      end

      track_list_hash = {
        :category => n,
        :track_count => 20,
        :tracks => tracks
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
