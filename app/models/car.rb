class Car
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_cars'

  # Minimum amount of ratings a car needs before its aggregate rating is shown publicly
  RATING_VOTE_THRESHOLD = 2

  belongs_to :season
  has_many :car_ratings, :dependent => :destroy

  field :name, :type => String
  field :speed, :type => Float
  field :accel, :type => Float
  field :weight, :type => Float
  field :multiplier, :type => Float
  field :folder_name, :type => String
  field :category, :type => Integer
  field :author, :type => String
  field :stock, :type => Boolean, :default => false
  field :active, :type => Boolean, :default => true
  field :carbox_filename, :type => String, :default => "carbox.bmp"

  validates_presence_of :name
  validates_presence_of :speed
  validates_presence_of :accel
  validates_presence_of :weight
  validates_presence_of :multiplier
  validates_presence_of :folder_name
  validates_presence_of :category
  validates_presence_of :author
  # Booleans: use inclusion rather than presence, otherwise a value of `false`
  # (e.g. a non-stock or disabled car) fails `presence` since `false.blank?` is true.
  validates_inclusion_of :stock, :in => [true, false]
  validates_inclusion_of :active, :in => [true, false]

  def thumbnail_url
    box_filename = carbox_filename.nil? ? 'carbox.bmp' : carbox_filename

    "#{ORG::CARS_REPO_URL}/cars/#{folder_name}/#{box_filename}"
  end

  # @return [Integer] Amount of ratings submitted for this car
  def rating_count
    @rating_count ||= car_ratings.count
  end

  # @return [Float, nil] Average of every submitted rating's composite score, or nil if there are none yet
  def average_rating
    return nil if rating_count.zero?

    @average_rating ||= car_ratings.collect(&:average_score).sum / rating_count
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
    car_ratings.each do |rating|
      bucket = rating.average_score.round.clamp(1, 5)
      distribution[bucket] += 1
    end
    distribution
  end

  def carry_over_ratings_from_previous_season!
    return false if season.nil?
    return false if car_ratings.exists?

    Season.where(:start_date.lt => season.start_date).order_by(:start_date.desc).each do |previous_season|
      previous_car = previous_season.cars.where(:name => name).first
      next if previous_car.nil? || previous_car.car_ratings.empty?

      previous_car.car_ratings.each do |previous_rating|
        car_ratings.create!(
          :user_id => previous_rating.user_id,
          :handling_rating => previous_rating.handling_rating,
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
