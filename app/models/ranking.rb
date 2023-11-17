class Ranking
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_rankings'

  belongs_to :season
  has_many :sessions

  embeds_many :racer_result_entries

  accepts_nested_attributes_for :racer_result_entries

  field :number, :type => Integer

  validates_presence_of :number

  def get_rank(user)
    i = 0
    entry = nil
    racer_result_entries.each do |e|
      unless e.username.eql?(user.username)
        i += 1
        next
      end

      entry = e
      break
    end

    return '-' if entry.nil?

    i + 1
  end
end
