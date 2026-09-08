class Track
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_tracks'

  # Minimum amount of ratings a track needs before its aggregate rating is shown publicly
  RATING_VOTE_THRESHOLD = 2

  belongs_to :season
  has_many :track_ratings, :dependent => :destroy

  field :name, :type => String
  field :short_name, :type => String
  field :difficulty, :type => Integer
  field :length, :type => Integer
  field :folder_name, :type => String
  field :author, :type => String
  field :stock, :type => Boolean, :default => false
  field :lego, :type => Boolean, :default => false
  field :active, :type => Boolean, :default => true
  field :average_lap_time, :type => Integer

  validates_presence_of :name
  validates_presence_of :short_name
  validates_presence_of :difficulty
  validates_presence_of :length
  validates_presence_of :folder_name
  validates_presence_of :author
  # Booleans: use inclusion rather than presence, otherwise a value of `false`
  # (e.g. a non-stock or disabled track) fails `presence` since `false.blank?` is true.
  validates_inclusion_of :stock, :in => [true, false]
  validates_inclusion_of :lego, :in => [true, false]
  validates_inclusion_of :active, :in => [true, false]
  validates_presence_of :average_lap_time

  def lap_count(category)
    normalized_avg_time = average_lap_time * SYS::CATEGORY::LAP_COUNT_CONSTANT[category]
    return 3 if normalized_avg_time.zero?

    lap_count = 135 / normalized_avg_time
    return 2 if lap_count < 2

    lap_count.round
  end

  def name_variations
    [name, "#{name} R", "#{name} M", "#{name} RM"]
  end

  def thumbnail_url
    "#{ORG::TRACKS_REPO_URL}/gfx/#{folder_name}.bmp"
  end

  # @return [String] Capitalised name of the track difficulty as a string
  def difficulty_name
    SYS::RVGL_TRACK_DIFFICULTY_NAMES[difficulty].capitalize.gsub(/-[a-z]/, &:upcase)
  end

  # @return [Integer] Amount of ratings submitted for this track
  def rating_count
    @rating_count ||= track_ratings.count
  end

  # @return [Float, nil] Average of every submitted rating's composite score, or nil if there are none yet
  def average_rating
    return nil if rating_count.zero?

    @average_rating ||= track_ratings.collect(&:average_score).sum / rating_count
  end

  # @return [Float, nil] Rating rounded to the nearest half-star (1.0-5.0) to display publicly, or nil until
  #   the vote threshold is met
  def display_rating
    return nil if rating_count < RATING_VOTE_THRESHOLD

    ((average_rating * 2).round / 2.0).clamp(1.0, 5.0)
  end

  # @return [Hash{Integer=>Integer}] number of ratings whose composite score rounds to each 1-5
  #   star bucket, e.g. { 1 => 3, 2 => 0, 3 => 12, 4 => 40, 5 => 88 }
  def rating_distribution
    distribution = (1..5).index_with { 0 }
    track_ratings.each do |rating|
      bucket = rating.average_score.round.clamp(1, 5)
      distribution[bucket] += 1
    end
    distribution
  end

  def carry_over_ratings_from_previous_season!
    return false if season.nil?
    return false if track_ratings.exists?

    Season.where(:start_date.lt => season.start_date).order_by(:start_date.desc).each do |previous_season|
      previous_track = previous_season.tracks.where(:name => name).first
      next if previous_track.nil? || previous_track.track_ratings.empty?

      previous_track.track_ratings.each do |previous_rating|
        track_ratings.create!(
          :user_id => previous_rating.user_id,
          :gameplay_rating => previous_rating.gameplay_rating,
          :visuals_rating => previous_rating.visuals_rating,
          :audio_rating => previous_rating.audio_rating,
          :fun_rating => previous_rating.fun_rating
        )
      end

      return true
    end

    false
  end
end
