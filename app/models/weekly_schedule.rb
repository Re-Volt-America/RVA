class WeeklySchedule
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes

  store_in :database => 'rv_weekly_schedules'

  embeds_many :track_lists

  accepts_nested_attributes_for :track_lists

  belongs_to :season

  field :start_date, :type => Date
end
