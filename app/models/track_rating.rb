class TrackRating
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_track_ratings'

  belongs_to :track
  belongs_to :user

  field :gameplay_rating, :type => Integer
  field :visuals_rating, :type => Integer
  field :audio_rating, :type => Integer
  field :fun_rating, :type => Integer

  RATING_FIELDS = [:gameplay_rating, :visuals_rating, :audio_rating, :fun_rating].freeze

  validates_uniqueness_of :user_id, :scope => :track_id
  RATING_FIELDS.each do |rating_field|
    validates rating_field, :presence => true, :inclusion => { :in => 1..5 }
  end

  # Combines the Gameplay, Visuals, Audio and Fun category ratings into a single 1.0-5.0 score.
  # @return [Float] the composite score for this rating
  def average_score
    mean(gameplay_rating, visuals_rating, audio_rating, fun_rating)
  end

  private

  def mean(*values)
    values.sum.to_f / values.size
  end
end
