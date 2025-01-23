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

    track_lists = {}
    num_track_lists = 0

    # Prepare lego tracks
    lego_tracks = @season.tracks.where(:lego => true).shuffle.to_a
    lego_track_pairs = prepare_lego_track_pairs(lego_tracks)

    # Randomly assign lego track pairs to consecutive track list positions
    lego_track_assignments = assign_lego_track_pairs(lego_track_pairs, category_numbers.length)

    # Generate track lists for each category
    season_tracks = @season.tracks.where(:lego => false).to_a.shuffle
    reverse_tracks = []
    reverse = false

    category_numbers.each do |category|
      season_tracks = @season.tracks.where(:lego => false).to_a.shuffle if season_tracks.length < 20

      # Get lego track assignment for this position if it exists
      lego_assignment = lego_track_assignments[num_track_lists]

      # Generate track list entries
      track_list_entries = generate_track_list_entries(
        category,
        season_tracks,
        reverse_tracks,
        reverse,
        lego_assignment
      )

      track_list_hash = {
        :category => category,
        :track_count => 20,
        :track_list_entries => track_list_entries
      }

      track_lists = track_lists.merge(num_track_lists.to_s => track_list_hash)

      # Reset reverse tracks if we just used them
      reverse_tracks = [] if reverse

      num_track_lists += 1
      reverse = !reverse
    end

    WeeklySchedule.new(
      :season => @season,
      :start_date => @start_date,
      :track_lists => track_lists
    )
  end

  private

  def prepare_lego_track_pairs(lego_tracks)
    # Remove one track if we have an odd number
    lego_tracks.pop if lego_tracks.length.odd?

    # Create pairs of tracks
    lego_tracks.each_slice(2).to_a
  end

  def assign_lego_track_pairs(lego_track_pairs, total_track_lists)
    assignments = {}

    # For each pair of lego tracks
    lego_track_pairs.each do |pair|
      # Find two consecutive positions that haven't been assigned yet
      available_positions = (0...total_track_lists).each_cons(2).to_a.shuffle

      available_positions.each do |pos1, pos2|
        next unless !assignments.key?(pos1) && !assignments.key?(pos2)

        # Randomly choose position in tracklist (1-20) for both days
        track_position = rand(20)
        assignments[pos1] = { :track => pair[0], :position => track_position }
        assignments[pos2] = { :track => pair[1], :position => track_position }
        break
      end
    end

    assignments
  end

  def generate_track_list_entries(category, season_tracks, reverse_tracks, reverse, lego_assignment)
    entries = {}
    tracks_to_use = reverse ? reverse_tracks : []
    num_entries = 0

    # If we're not in reverse mode, prepare new tracks
    unless reverse
      20.times do
        track = season_tracks.pop
        reverse_tracks << track if track && !track.lego # Only add non-lego tracks to reverse list
        tracks_to_use << track if track
      end
    end

    # Generate entries for each position
    20.times do |position|
      if lego_assignment && position == lego_assignment[:position]
        # Insert lego track at assigned position
        track = lego_assignment[:track]
        entries[num_entries.to_s] = {
          :track_name => track.name,
          :stock => track.stock,
          :lego => true,
          :lap_count => track.lap_count(category)
        }
      else
        # Insert regular track
        track = tracks_to_use[position]
        if track
          entries[num_entries.to_s] = {
            :track_name => reverse ? "#{track.name} R" : track.name,
            :stock => track.stock,
            :lego => false,
            :lap_count => track.lap_count(category)
          }
        end
      end

      num_entries += 1
    end

    entries
  end
end
