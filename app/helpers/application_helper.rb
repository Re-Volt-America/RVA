module ApplicationHelper
  def is_production?
    Rails.env == 'production' || Rails.env == 'staging'
  end

  # Check if the passed user is an admin
  # @return [Boolean] true if the current user is an admin, false otherwise
  def user_is_admin?(user = current_user)
    user && user.admin?
  end

  # Check if the passed user is a moderator
  # @return [Boolean] true if the current user is a moderator, false otherwise
  def user_is_mod?(user = current_user)
    user && user.mod?
  end

  # Check if the passed user is an organizer
  # @return [Boolean] true if the current user is an organizer, false otherwise
  def user_is_organizer(user = current_user)
    user && user.organizer?
  end

  # Check if the passed user has a staff role
  # @return [Boolean] true if the current user either an admin, a mod or an organizer
  def user_is_staff?(user = current_user)
    user && (user.admin? || user.mod? || user.organizer?)
  end

  # Check whether the passed object evaluates to a true expression
  # @param obj [Object]
  # @return true if the object can be evaluated to "true"
  def true?(obj)
    obj.to_s.downcase == 'true'
  end

  # @param datetime [DateTime]
  # @return [String] Pretty date string (i.e: April 21st, 2022)
  def pretty_datetime(datetime)
    datetime.strftime("%B #{datetime.day.ordinalize}, %Y")
  end
end
