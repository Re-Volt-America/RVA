# Tracks a single background import of an uploaded Session log.
#
# When an admin uploads a Session, the raw CSV is stored on this record and a
# SessionImportJob is enqueued. The job parses the log in the background and
# updates this record with its progress, timing and result, which powers the
# "recently parsed / currently parsing" view in the Administration Panel.
class SessionImport
  include Mongoid::Document
  include SessionLogUploader::Attachment(:session_log)
  include Mongoid::Timestamps

  store_in :database => 'rv_sessions'

  PENDING    = 'pending'.freeze
  PROCESSING = 'processing'.freeze
  COMPLETED  = 'completed'.freeze
  FAILED     = 'failed'.freeze
  STATUSES   = [PENDING, PROCESSING, COMPLETED, FAILED].freeze

  # The admin/organizer who uploaded the Session. Lives in the rv_users
  # database, referenced the same way Session references its hosts.
  belongs_to :uploaded_by, :class_name => 'User', :inverse_of => nil, :optional => true

  field :status, :type => String, :default => PENDING
  field :error_message, :type => String
  field :session_log_data, :type => String

  # Parameters captured from the upload form, needed to (re)run the import.
  field :ranking_id, :type => String
  field :category, :type => Integer
  field :teams, :type => Boolean, :default => false
  field :original_filename, :type => String

  # Result & timing information.
  field :session_id, :type => BSON::ObjectId
  field :session_number, :type => Integer
  field :enqueued_at, :type => Time
  field :started_at, :type => Time
  field :finished_at, :type => Time
  field :duration_ms, :type => Integer

  validates_inclusion_of :status, :in => STATUSES

  index({ :status => 1 })
  index({ :created_at => -1 })

  scope :in_progress, -> { where(:status.in => [PENDING, PROCESSING]).order_by(:created_at.desc) }
  scope :finished, -> { where(:status.in => [COMPLETED, FAILED]).order_by(:finished_at.desc) }

  def pending?
    status == PENDING
  end

  def processing?
    status == PROCESSING
  end

  def completed?
    status == COMPLETED
  end

  def failed?
    status == FAILED
  end

  def in_progress?
    pending? || processing?
  end

  # Human friendly duration in seconds (nil until we have timing data).
  def duration_seconds
    return duration_ms / 1000.0 if duration_ms
    return nil unless started_at

    ((finished_at || Time.current) - started_at).to_f
  end

  # The Session produced by a successful import, if it still exists.
  def result_session
    return nil unless session_id

    Session.where(:id => session_id).first
  end

  def ranking
    return nil if ranking_id.blank?

    Ranking.where(:id => ranking_id).first
  end
end
