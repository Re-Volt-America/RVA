module ApplicationHelper
  def is_production?
    Rails.env == 'production' || Rails.env == 'staging'
  end

  # Check if the passed user is an admin
  # @return [Boolean] true if the current user is an admin, false otherwise
  def user_is_admin?(user = current_user)
    user && user.admin?
  end

  # Check if the passed user has a staff role
  # @return [Boolean] true if the current user either an admin, a mod or an organizer
  def user_is_staff?(user = current_user)
    user && (user.admin? || user.mod? || user.organizer?)
  end

  def true?(obj)
    obj.to_s.downcase == "true"
  end
end
