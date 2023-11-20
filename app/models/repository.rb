class Repository
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :database => 'rv_repos'

  field :title, :type => String
  field :description, :type => String
  field :visible, :type => Boolean
  field :provider, :type => String
  field :namespace, :type => String
  field :repo, :type => String
  field :open, :type => Boolean
  field :branch, :type => String

  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :visible
  validates_presence_of :provider
  validates_presence_of :namespace
  validates_presence_of :repo
  validates_presence_of :open
  validates_presence_of :branch

  def get_url
    "https://#{provider}.com/#{namespace}/#{repo}"
  end
end
