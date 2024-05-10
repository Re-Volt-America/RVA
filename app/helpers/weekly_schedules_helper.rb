module WeeklySchedulesHelper
  # @return The most recent weekly schedule, or nil if there are no schedules in the system
  def current_schedule
    WeeklySchedule.all.max_by { |s| s[:start_date] }
  end
end
