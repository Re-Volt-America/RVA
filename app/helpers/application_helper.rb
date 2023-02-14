module ApplicationHelper
  def is_production?
    Rails.env == 'production' || Rails.env == 'staging'
  end
end
